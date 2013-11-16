def set_layout()
  @layout ||= "layouts/#{logged_in? ? 'primary' : 'guest' }".to_sym
end

configure do
  Sinatra::API.on :resource_located do |resource, name|
    Sinatra::API.instance.js_inject(resource)
  end
end

# anonymous vs authenticated view layouts
before do
  set_layout

  if logged_in?
    js_inject(@user)
  end
end

# anonymous landing page
get '/' do
  pass if logged_in?

  erb "welcome/index"
end

# anonymous landing page
get '/' do
  @task = @user.current_task
  @work_session = @user.current_work_session

  pass unless @work_session

  redirect @work_session.url
end

get '/' do
  respond_to do |f|
    f.html do
      erb :"dashboard/idle"
    end
  end
end