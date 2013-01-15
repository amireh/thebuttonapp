route_namespace '/settings' do
  condition do
    restrict_to(:user)
  end

  before do
    current_page("manage")
  end

  [ "account", "notifications", 'password' ].each { |domain|
    get "/#{domain}" do
      @standalone = true

      erb :"/users/settings/#{domain}"
    end
  }

  post "/account" do
    if current_user.update({
      name: params[:name],
      email: params[:email],
      gravatar_email: params[:gravatar_email] }) then
      flash[:notice] = "Your account info has been updated."
    else
      flash[:error] = current_user.all_errors
    end

    redirect back
  end

  post '/password' do

    pw = User.encrypt(params[:password][:current])

    if current_user.password != pw then
      flash[:error] = "The current password you've entered isn't correct!"
      return redirect back
    end

    # validate length
    # we can't do it in the model because it gets the encrypted version
    # which will always be longer than 8
    if params[:password][:new].length < 7
      flash[:error] = "That password is too short, it must be at least 7 characters long."
      return redirect back
    end

    back_url = back

    @user.password              = User.encrypt(params[:password][:new])
    @user.password_confirmation = User.encrypt(params[:password][:confirmation])

    if current_user.save then
      notices = current_user.pending_notices({ type: 'password' })
      unless notices.empty?
        back_url = "/"
        notices.each { |n| n.accept! }
      end
      flash[:notice] = "Your password has been changed."
    else
      flash[:error] = @user.all_errors
    end

    redirect back_url
  end

end


