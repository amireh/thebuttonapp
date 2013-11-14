def set_layout()
  @layout ||= "layouts/#{logged_in? ? 'primary' : 'guest' }".to_sym
end

def js_env(opts = {})
  @@js_injections ||= 0
  @@js_injections += 1

  script_id = "injection_#{@@js_injections}"
  env = {}
  opts.each_pair do |k,v|
    env[k.upcase] = JSON.parse v
  end

  content_for :js_injections do
    """
    <script id=\"#{script_id}\">
      window.ENV = window.ENV || {};

      _.extend(window.ENV, #{env.to_json});

      document.getElementById('#{script_id}').remove();
    </script>
    """
  end
end

# anonymous vs authenticated view layouts
before do
  set_layout
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
      js_env({
        :user => rabl(:"users/show", object: @user)
      })

      erb :"dashboard/idle"
    end
  end
end