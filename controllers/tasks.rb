route_namespace '/tasks' do
  condition do restrict_to(:user) end

  get '/new' do
    @t = current_user.tasks.new
    erb :"/tasks/new"
  end

  get '/:id/work_sessions' do |task_id|
    unless @t = current_user.tasks.get(task_id.to_i)
      halt 400, "No such task"
    end

    erb :"/tasks/work_sessions"
  end

  get '/:id/edit' do |task_id|
    unless @t = current_user.tasks.get(task_id.to_i)
      halt 400, "No such task"
    end

    erb :"/tasks/new", layout: false
  end

  get '/history' do
    erb :"/tasks/history"
  end

  get '/current' do
    erb :"/tasks/current"
  end

  get '/:id/mark' do |task_id|
    unless t = current_user.tasks.get(task_id.to_i)
      halt 400, "No such task"
    end

    if params[:as] && ['complete', 'pending', 'abandoned'].include?(params[:as])
      t.update({ status: params[:as].to_sym })
      if @user.current_session && @user.current_session.task.id == t.id
        @user.current_session.finish
      end
    else
      halt 400, "Bad task status #{params[:as]}"
    end

    redirect '/'
  end

  get '/:id/resume' do |task_id|
    unless t = current_user.tasks.get(task_id.to_i)
      halt 400, "No such task"
    end

    if cws = @user.current_session
      cws.finish
    end

    t.update({ status: :active })

    unless ws = @user.work_sessions.create({ task: t, active: true })
      flash[:error] = ws.all_errors
    else
      flash[:notice] = "Work session started!"
    end

    return redirect '/'
  end

  def extract_tags_and_details(params)
    name = params[:task][:name]
    details = params[:task][:details]

    tags = []
    if name =~ /#\w+/
      tag_names = []
      name.gsub(/#(\w|\-|\_)+\s*/) { |match|
        tag_names << match.strip.gsub('#', '')
      }

      if details
        details.gsub(/#(\w|\-|\_)+\s*/) { |match|
          tag_names << match.strip.gsub('#', '')
        }
      end

      tag_names.each do |name|
        tags << @user.tags.first_or_create({ name: name })
      end
    end

    # any detailed description written? (has to push two \n\n after the task name)
    unless details
      parts = name.split("\n")
      details = ''
      if parts.length > 2
        # it has a detailed description
        name    = parts[0]
        details = parts[2..-1].join("\n")
      end
    end

    [name, tags, details]
  end

  post '/:id' do |task_id|
    unless t = current_user.tasks.get(task_id.to_i)
      halt 400, "No such task"
    end

    name, tags, details = extract_tags_and_details(params)

    if t.update({ name: name, tags: tags, details: details })
      flash[:notice] = "Task #{t.name} has been updated."
    else
      flash[:error] = t.all_errors
    end

    return redirect '/'
  end
end