PROJECT_API_FIELDS = {
  name: nil,
  billing_rate: nil,
  billing_currency: nil,
  billing_basis: nil
}

get '/projects', auth: [ :user ] do
  @projects = @user.clients.projects
  erb :"projects/index"
end

get '/clients/:client_id/projects', auth: [ :user ], requires: [ :client ] do
  @projects = @client.projects
  erb :"projects/index"
end

get '/clients/:client_id/projects/new', auth: [ :user ], requires: [ :client ] do
  @project = @client.projects.new
  erb :"projects/new"
end

get '/clients/:client_id/projects/:project_id', requires: [ :client, :project ] do
  erb :"projects/show"
end

get '/clients/:client_id/projects/:project_id/edit', requires: [ :client, :project ] do
  erb :"projects/edit"
end

post '/clients/:client_id/projects', auth: [ :user ], requires: [ :client ] do
  api_required!({
    name: nil
  })

  api_optional!(PROJECT_API_FIELDS.except(:name))

  @project = @client.projects.create(api_params)

  if @project.saved?
    flash[:notice] = 'Project registered.'
  else
    halt 400, @project.all_errors
  end

  redirect @project.url
end

put '/clients/:client_id/projects/:project_id', auth: [ :user ], requires: [ :client, :project ] do
  api_optional!(PROJECT_API_FIELDS)

  if @project.update( api_params )
    flash[:notice] = 'Project updated.'
  else
    flash[:error] = @project.all_errors
  end

  redirect back
end

delete '/clients/:client_id/projects/:project_id', requires: [ :client, :project ] do
  if @project.destroy
    flash[:notice] = 'Project removed.'
  else
    flash[:error] = @project.all_errors
  end

  redirect @client.url
end