# encoding: utf-8

module Authentication
  module Filters
    def requires_authentication(*args)
      send(:before_action, *args) do |controller|
        controller.send(:require_user_account) unless Sugar.public_browsing?
      end
    end

    def requires_user(*args)
      send(:before_action, *args) do |controller|
        controller.send(:require_user_account)
      end
    end

    def requires_admin(*args)
      send(:before_action, *args) do |controller|
        controller.send(:verify_user, admin: true)
      end
    end

    def requires_moderator(*args)
      send(:before_action, *args) do |controller|
        controller.send(:verify_user, moderator: true)
      end
    end

    def requires_user_admin(*args)
      send(:before_action, *args) do |controller|
        controller.send(:verify_user, user_admin: true)
      end
    end
  end
end
