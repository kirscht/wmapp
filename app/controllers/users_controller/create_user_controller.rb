class UsersController < ApplicationController
  module CreateUserController
    extend ActiveSupport::Concern

    included do
      before_action :find_invite,               only: [:new, :create]
      before_action :check_for_expired_invite,  only: [:new, :create]
      before_action :check_for_signups_allowed, only: [:new, :create]
    end

    def new
      if @invite
        session[:invite_token] = @invite.token
        @user = @invite.user.invitees.new(facebook_user_params)
        @user.email = @invite.email
      else
        @user = User.new(facebook_user_params)
      end
    end

    def create
      @user = User.new(new_user_params)
      @user.invite = @invite # This can be nil

      if @user.save
        finalize_successful_signup
        redirect_to user_profile_url(id: @user.username)
      else
        flash.now[:notice] = "Could not create your account, " \
                             "please fill in all required fields."
        render action: :new
      end
    end

    private

    def new_user_params
      params.require(:user).permit(:username, *allowed_params)
    end

    def find_invite
      @invite = Invite.find_by_token(invite_token) if invite_token?
    end

    def invite_token
      params[:token] || session[:invite_token]
    end

    def invite_token?
      invite_token ? true : false
    end

    def finalize_successful_signup
      Mailer.new_user(@user, login_users_url).deliver_now if @user.email?
      session.delete(:facebook_user_params)
      session.delete(:invite_token)
      @current_user = @user
    end

    def check_for_expired_invite
      if @invite && @invite.expired?
        session.delete(:invite_token)
        flash[:notice] = "Your invite has expired"
        redirect_to login_users_url
      end
    end

    def check_for_signups_allowed
      if !Sugar.config.signups_allowed && User.any? && !@invite
        flash[:notice] = "Signups are not allowed"
        redirect_to login_users_url
      end
    end

    def facebook_user_params
      session[:facebook_user_params] || {}
    end
  end
end
