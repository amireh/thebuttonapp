def set_layout()
  @layout ||= "layouts/#{logged_in? ? 'primary' : 'guest' }".to_sym
  @layout = false if request.xhr?
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

  erb "dashboard"
end

