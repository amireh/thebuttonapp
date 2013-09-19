def set_layout()
  @layout ||= "layouts/#{logged_in? ? 'primary' : 'guest' }".to_sym
end

# anonymous vs authenticated view layouts
before do
  set_layout
end

# anonymous landing page
get '/' do
  pass if logged_in?

  current_page("welcome")

  erb "welcome/index"
end

# anonymous landing page
get '/' do
  current_page("dashboard")

  @t = @task = @user.current_task
  @ws = @user.current_work_session

  erb "dashboard"
end

