post '/work_sessions/:work_session_id/notes', requires: [ :work_session ] do
  unless params[:content].strip.empty?
    if n = @ws.notes.create({ content: params[:content] })
      flash[:notice] = "Note attached!"
    else
      flash[:error] = n.all_errors
    end
  end

  redirect back
end

get '/work_sessions/:work_session_id/notes/:note_id/edit', requires: [ :work_session, :note ] do
  erb :"notes/_edit", layout: false
end

post '/work_sessions/:work_session_id/notes/:note_id', requires: [ :work_session, :note ] do
  api_required!({
    content: nil
  })

  if @note.update(api_params)
    flash[:notice] = "Note updated!"
  else
    flash[:error] = @note.all_errors
  end

  redirect back
end

delete '/work_sessions/:work_session_id/notes/:note_id', requires: [ :work_session, :note ] do
  if @note.destroy
    flash[:notice] = 'Note removed!'
  else
    flash[:error] = @note.all_errors
  end

  redirect back
end
