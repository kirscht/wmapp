# encoding: utf-8

class DiscussionRelationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion

  before_validation :ensure_flags_are_mutually_exclusive

  after_save :update_user_caches!
  after_destroy :update_user_caches!

  class << self
    def define(user, discussion, options = {})
      relationship = find_by(user_id: user.id, discussion_id: discussion.id)
      relationship ||= DiscussionRelationship.create(
        user_id: user.id,
        discussion_id: discussion.id
      )
      relationship.update_attributes(options.merge(trusted: discussion.trusted))
      relationship.save
      relationship
    end
  end

  def update_user_caches!
    user.update(
      participated_count: relationship_count(:participated),
      following_count: relationship_count(:following),
      favorites_count: relationship_count(:favorite),
      hidden_count: relationship_count(:hidden)
    )
  end

  protected

  def favorite_or_following_enabled?
    (favorite_changed? && favorite?) ||
      (following_changed? && following?)
  end

  def ensure_flags_are_mutually_exclusive
    if hidden?
      if hidden_changed?
        # Unfollow if discussion has been hidden
        self.following = false
        self.favorite = false
      elsif favorite_or_following_enabled?
        # Unhide if discussion has been followed/favorited
        self.hidden = false
      end
    end
    true
  end

  def relationship_count(flag)
    DiscussionRelationship.where(
      :user_id => user_id,
      flag => true
    ).count
  end
end
