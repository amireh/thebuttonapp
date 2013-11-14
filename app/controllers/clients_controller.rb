get '/clients', auth: [ :user ] do
  erb :"clients/index"
end

get '/clients/new', auth: [ :user ] do
  @client = @user.clients.new
  erb :"clients/new"
end

get '/clients/:client_id', requires: [ :client ] do
  erb :"clients/show"
end

get '/clients/:client_id/edit', requires: [ :client ] do
  erb :"clients/edit"
end

delete '/clients/:client_id', requires: [ :client ] do
  if @client.destroy
    flash[:notice] = 'Client removed.'
  else
    flash[:error] = @client.all_errors
  end

  redirect '/clients'
end

post '/clients', auth: [ :user ] do
  api_required!({
    name: nil
  })

  @client = @user.clients.create(api_params)

  if @client.saved?
    flash[:notice] = 'Client registered.'
  else
    flash[:error] = @client.all_errors
  end

  redirect @client.url
end

post '/clients/:client_id', auth: [ :user ], requires: [ :client ] do
  api_optional!({
    name: nil
  })

  if @client.update( api_params )
    flash[:notice] = 'Client updated'
  else
    flash[:error] = @client.all_errors
  end

  redirect back
end