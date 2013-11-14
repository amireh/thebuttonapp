Sinatra::API.alias_resource :work_session, :ws

API_WORK_SESSION_FIELDS = {
  summary: nil,
  duration: nil,
  active: nil,
  started_at: nil,
  task_status: lambda { |v|
    unless Task::Statuses.include?((v||'').to_sym)
      halt 400, "Task status must be one of: #{Task::Statuses.join(',')}"
    end
  }
}

get '/tasks/:task_id/work_sessions', auth: [ :user ], requires: [ :task ] do
  @work_sessions = @task.work_sessions
  @tag_names = tag_collection(@work_sessions)
  erb :"work_sessions/index"
end

post '/tasks/:task_id/work_sessions', auth: [ :user ], requires: [ :task ] do
  unless @work_session = @task.work_sessions.create({ active: true })
    halt 400, @work_session.all_errors
  end

  redirect @work_session.url
end

get '/tasks/:task_id/work_sessions/:work_session_id', auth: [ :user ], requires: [ :task,  :work_session ] do
  unless @work_session.active?
    return redirect '/'
  end

  respond_to do |f|
    f.html do
      js_env({
        :user => rabl(:"users/show", object: @user),
        :task => rabl(:"tasks/show", object: @task),
        :work_session => rabl(:"work_sessions/show", object: @work_session)
      })

      erb :"dashboard/active"
    end
  end
end

get '/tasks/:task_id/work_sessions/:work_session_id/edit', auth: [ :user ], requires: [ :task,  :work_session ] do
  erb :"/work_sessions/edit", layout: false
end

put '/tasks/:task_id/work_sessions/:work_session_id',
  provides: [ :html, :json ], requires: [ :task, :work_session ] do
  api_optional!(API_WORK_SESSION_FIELDS)

  api_transform!(:started_at) do |value|
    DateTime.parse value
  end

  task_status = api_consume!(:task_status)

  unless @work_session.update(api_params)
    halt 400, @work_session.all_errors
  end

  if task_status
    @task.update({ status: task_status })
    @work_session.finish
  end

  respond_to do |f|
    f.html { redirect back }
    f.json { rabl :"work_sessions/show", object: @work_session }
  end
end

delete '/tasks/:task_id/work_sessions/:work_session_id', requires: [ :task, :work_session ] do
  unless @work_session.destroy
    halt 400, @work_session.all_errors
  end

  flash[:notice] = "Work session has been removed."

  redirect back
end
