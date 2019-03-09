# encoding: utf-8

class Mailer < ActionMailer::Base
  default from: proc { Sugar.config.mail_sender || "no-reply@example.com" }

  def invite(invite, login_url)
    @invite    = invite
    @login_url = login_url
    mail(
      to:      @invite.email,
      subject: "#{@invite.user.realname_or_username} has invited you to " \
        "#{Sugar.config.forum_name}!"
    )
  end

  def new_user(user, login_url)
    @user      = user
    @login_url = login_url
    mail(
      to:      @user.email,
      subject: "Welcome to #{Sugar.config.forum_name}!"
    )
  end

  def password_reset(email, url)
    @url = url
    mail(
      to: email,
      subject: "Password reset for #{Sugar.config.forum_name}"
    )
  end

  def new_post(username, email, url, conversation)
    @username = username
    @url = url
    @conversation = conversation
    mail(
      to: email,
      subject: "New post in conversation at #{Sugar.config.forum_name}!"
    )
  end
end
