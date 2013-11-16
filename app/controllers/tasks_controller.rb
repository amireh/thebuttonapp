API_TASK_FIELDS = {
  name: :string,
  details: :string,
  status: lambda { |v|
    unless Task::Statuses.include?((v||'').to_sym)
      halt 400, "Task status must be one of: #{Task::Statuses.join(',')}"
    end
  },

  new_project_id: :integer
}

post '/projects/:project_id/tasks', requires: [ :project ] do
  api_required!(API_TASK_FIELDS.slice(:name))
  api_optional!(API_TASK_FIELDS.except(:name))

  @task = @project.tasks.create(api_params.merge({
    status: :active
  }))

  unless @task.saved?
    halt 400, @task.all_errors
  end

  flash[:notice] = 'Task created.'

  @work_session = @task.work_sessions.create({ active: true })
  redirect @work_session.url
end

get '/projects/:project_id/tasks/:task_id/edit', requires: [ :project, :task ] do
  erb :"/tasks/_edit", layout: false
end

put '/projects/:project_id/tasks/:task_id', requires: [ :project, :task ] do
  api_optional!(API_TASK_FIELDS)

  api_transform!(:status) { |v| v.to_sym }
  project_id = api_consume!(:new_project_id)

  unless @task.update(api_params.merge({ project_id: project_id || @project.id }))
    halt 400, @task.all_errors
  end


  respond_to do |f|
    f.json do
      rabl :"tasks/show", object: @task
    end

    f.html do
      flash[:notice] = "Task #{@task.name} has been updated."
      redirect '/'
    end
  end
end


# get '/new' do
#   @t = current_user.tasks.new
#   erb :"/tasks/new"
# end

# get '/:task_id/work_sessions', requires: [ :task ] do
#   erb :"/tasks/work_sessions"
# end


get '/tasks/history' do
  erb :"/tasks/history"
end

get '/tasks/current' do
  erb :"/tasks/current"
end

# get '/:id/mark' do |task_id|
#   unless t = current_user.tasks.get(task_id.to_i)
#     halt 400, "No such task"
#   end

#   if params[:as] && ['complete', 'pending', 'abandoned'].include?(params[:as])
#     t.update({ status: params[:as].to_sym })
#     if @user.current_session && @user.current_session.task.id == t.id
#       @user.current_session.finish
#     end
#   else
#     halt 400, "Bad task status #{params[:as]}"
#   end

#   redirect '/'
# end

# get '/:id/resume' do |task_id|
#   unless t = current_user.tasks.get(task_id.to_i)
#     halt 400, "No such task"
#   end

#   if cws = @user.current_session
#     cws.finish
#   end

#   t.update({ status: :active })

#   unless ws = @user.work_sessions.create({ task: t, active: true })
#     flash[:error] = ws.all_errors
#   else
#     flash[:notice] = "Work session started!"
#   end

#   return redirect '/'
# end

# def extract_tags(name, details)
#   tags = []
#   if name =~ /#\w+/
#     tag_names = []
#     name.gsub(/#(\w|\-|\_)+\s*/) { |match|
#       tag_names << match.strip.gsub('#', '')
#     }

#     if details
#       details.gsub(/#(\w|\-|\_)+\s*/) { |match|
#         tag_names << match.strip.gsub('#', '')
#       }
#     end

#     tag_names.each do |name|
#       tags << @user.tags.first_or_create({ name: name })
#     end
#   end

#   # any detailed description written? (has to push two \n\n after the task name)
#   unless details
#     parts = name.split("\n")
#     details = ''
#     if parts.length > 2
#       # it has a detailed description
#       name    = parts[0]
#       details = parts[2..-1].join("\n")
#     end
#   end

#   [ name, details, tags ]
# end
