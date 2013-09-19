route_namespace '/work_sessions' do
  Sinatra::API.alias_resource :work_session, :ws

  condition do restrict_to(:user) end

  get '/:work_session_id/edit', requires: [ :work_session ] do
    erb :"/work_sessions/edit", layout: false
  end

  post do
    t = nil

    case params[:whatimgoingtodo]
    when 'new'

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
    when 'manage'
      unless t = @user.tasks.get(params[:task][:id].to_i)
        halt 400, "No such task"
      end

      return redirect "/tasks/#{t.id}/work_sessions"
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

  post '/:work_session_id/update', requires: [ :work_session ] do
    if params[:summary]
      @ws.notes.destroy
      if !params[:summary].empty?
        @ws.notes.create({ content: params[:summary] })
      end
    end

    unless @ws.update(pick(params, %w[ duration ]))
      halt 400, @ws.all_errors
    end

    redirect back
  end

  post '/:work_session_id', requires: [ :work_session ] do |session_id|
    cws = @user.current_session

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

  delete '/:work_session_id', requires: [ :work_session ] do
    ws_id = @ws.id

    if @ws.destroy
      flash[:notice] = "Work session##{ws_id} has been removed and will no longer" +
      "count in the history of this task."
    else
      flash[:error] = @ws.all_errors
    end

    redirect back
  end

  post '/:work_session_id/notes', requires: [ :work_session ] do

    unless params[:content].strip.empty?
      if n = @ws.notes.create({ content: params[:content] })
        flash[:notice] = "Note attached!"
      else
        flash[:error] = n.all_errors
      end
    end

    redirect back
  end

  delete '/:work_session_id/notes/:note_id', requires: [ :work_session, :note ] do
    if @note.destroy
      flash[:notice] = 'Note removed!'
    else
      flash[:error] = @note.all_errors
    end

    redirect back
  end

end