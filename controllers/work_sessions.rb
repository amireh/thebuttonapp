route_namespace '/work_sessions' do
  condition do restrict_to(:user) end

  post do
    t = nil

    case params[:whatimgoingtodo]
    when 'new'

      puts params.inspect

      # any tagged entity?
      tn = params[:task][:name]
      tags = []
      if tn =~ /#\w+/
        tag_names = []
        tn.gsub(/#(\w|\-|\_)+\s*/) { |match|
          tag_names << match.strip.gsub('#', '')
        }

        tag_names.each do |name|
          tags << @user.tags.first_or_create({ name: name })
        end
      end

      # any detailed description written? (has to push two \n\n after the task name)
      parts = tn.split("\n")
      details = ''
      if parts.length > 2
        # it has a detailed description
        tn      = parts[0]
        details = parts[2..-1].join("\n")
      end

      t = @user.tasks.create({ name: tn, details: details, tags: tags })
    when 'resume'
      unless t = @user.tasks.get(params[:task][:id].to_i)
        halt 400, "No such task"
      end
    else
      flash[:error] = "You must want to do something!"
      redirect '/'
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

  post '/:id' do |session_id|
    cws = @user.current_session

    puts params.inspect

    unless cws && cws.id == session_id.to_i
      halt 400, "That's not the current active session!"
    end

    if params[:session][:note] && !params[:session][:note].empty?
      cws.notes.create({ content: params[:session][:note] })
    end

    if Task::Statuses.include?(params[:task][:status].to_sym)
      cws.task.update({ status: params[:task][:status].to_sym })
    end

    cws.finish

    redirect '/'
  end
end