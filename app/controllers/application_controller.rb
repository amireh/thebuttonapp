def set_layout()
  @layout ||= "layouts/#{logged_in? ? 'primary' : 'guest' }".to_sym
end

def js_env(opts = {})
  @@js_injections ||= 0
  @@js_injections += 1

  injection_id = "injection_#{@@js_injections}"
  injection = opts.map do |k,v|
    "window.ENV['#{k.upcase}'] = #{v};"
  end.join("\n")

  content_for :js_injections do
    """
    <script id=\"#{injection_id}\">
      window.ENV = window.ENV || {};
      #{injection}
      document.getElementById('#{injection_id}').remove();
    </script>
    """
  end
end

# anonymous vs authenticated view layouts
before do
  set_layout

  if logged_in?
    injections = {}
    injections[:user] = rabl(:"users/show", object: @user)
    injections[:client] = rabl(:"clients/show", object: @client) if @client
    injections[:project] = rabl(:"projects/show", object: @project) if @project

    js_env(injections)
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