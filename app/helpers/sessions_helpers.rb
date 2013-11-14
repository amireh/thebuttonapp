module Sinatra
  module SessionsHelper
    Messages = {
      lacks_privilege: "You lack privilege to visit this section.",
      unauthorized:    "You must sign in first"
    }

    def logged_in?
      !current_user.nil?
    end

    def restricted
      unless logged_in?
        flash[:error] = Messages[:unauthorized]
        redirect "/", 303
      end
    end

    def restricted!(scope = nil)
      halt 401, Messages[:unauthorized] unless logged_in?
    end

    def restrict_to(roles, options = {})
      roles = [ roles ] if roles.is_a? Symbol

      if roles.include?(:guest)
        if logged_in?
          flash[:warning] = "You're already logged in."
          redirect '/', 303
        end
      end

      if roles.include?(:active_user)
      #   restricted!
      #   @scope = current_user

      #   if current_user.locked?
      #     halt 403, "This action is for available to this account because it is locked."
      #   end

        # proceed to normal user auth
        roles << :user
      end

      if roles.include? :user || roles.include?(:admin)
        restricted!
        @scope = @user = current_user

        if options[:with].is_a?(Hash)
          options[:with].each_pair { |k, v|
            unless @user[k] == v
              halt 403, Messages[:lacks_privilege]
            end
          }
        elsif options[:with].is_a?(Proc)
          unless options[:with].call(@user)
            halt 403, Messages[:lacks_privilege]
          end
        end

        if roles.include?(:admin) && !@user.is_admin
          halt 403, Messages[:lacks_privilege]
        end
      end
    end

    def self.included(base)
      base.set(:auth) do |*roles|
        condition do
          restrict_to(roles)
        end
      end
    end

    def current_user
      return @user if @user

      # disabled: locking & public accounts
      # if params[:public_uid]
      #   @user = User.first({ id: params[:public_uid], is_public: true })
      #   @account = @user.accounts.first
      #   return @user
      # end

      return nil unless session[:id]
      @user = User.get(session[:id])
    end

    def authorize(user)
      if user.link
        # reset the state vars
        @user = nil
        @account = nil

        # mark the master account as the current user
        session[:id] = user.link.id

        # refresh the state vars
        @user     = current_user
      else
        session[:id] = user.id
      end
    end
  end

  helpers SessionsHelper
end