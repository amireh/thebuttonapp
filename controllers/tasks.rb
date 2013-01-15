route_namespace '/tasks' do
  condition do restrict_to(:user) end

  get '/new' do
    @t = current_user.tasks.new
    erb :"/tasks/new"
  end

  get '/history' do
    erb :"/tasks/history"
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

  post '/:id/notes' do |task_id|
    unless t = current_user.tasks.get(task_id.to_i)
      halt 400, "No such task"
    end

    unless params[:content].strip.empty?
      if n = t.notes.create({ content: params[:content] })
        flash[:notice] = "Note attached!"
      else
        flash[:error] = n.all_errors
      end
    end

    redirect '/'
  end

  post do
    e = @user.employers.get(params[:employer_id].to_i)

    cws = @user.current_session

    t = @user.tasks.create({ name: params[:name], employer: e })
    if t.saved?
      params[:notes] && params[:notes].each { |n| t.notes.create({ content: n })}

      if cws
        cws.task = t
        cws.save
      end

      flash[:notice] = "Task #{t.name} has been registered."
    else
      flash[:error] = t.all_errors
    end

    return redirect '/'
  end
end