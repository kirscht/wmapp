# encoding: utf-8

class DiscussionsController < ApplicationController
  include ExchangesController

  requires_authentication
  requires_user except: [:index, :show]

  before_action :find_exchange, except: [
    :index, :new, :create, :popular, :favorites, :following, :hidden
  ]
  before_action :verify_editable, only: [:edit, :update, :destroy]

  def index
    scope = if current_user?
              current_user.unhidden_discussions.viewable_by(current_user)
            else
              Discussion.viewable_by(nil)
            end
    @exchanges = scope.page(params[:page]).for_view
    respond_with_exchanges(@exchanges)
  end

  def popular
    @days = params[:days].to_i
    unless (1..180).cover?(@days)
      redirect_to popular_discussions_url(days: 7)
      return
    end
    @exchanges = Discussion.viewable_by(current_user)
                           .popular_in_the_last(@days.days)
                           .page(params[:page])
    respond_with_exchanges(@exchanges)
  end

  def favorites
    @section = :favorites
    @exchanges = current_user
                 .favorite_discussions
                 .viewable_by(current_user)
                 .page(params[:page])
                 .for_view
    respond_with_exchanges(@exchanges)
  end

  def following
    @section = :following
    @exchanges = current_user
                 .followed_discussions
                 .viewable_by(current_user)
                 .page(params[:page])
                 .for_view
    respond_with_exchanges(@exchanges)
  end

  def hidden
    @exchanges = current_user
                 .hidden_discussions
                 .viewable_by(current_user)
                 .page(params[:page])
                 .for_view
    respond_with_exchanges(@exchanges)
  end

  def show
    super
  end

  def new
    @exchange = Discussion.new
    render template: "exchanges/new"
  end

  def create
    @exchange = Discussion.create(exchange_params.merge(poster: current_user))
    if @exchange.valid?
      redirect_to @exchange
    else
      flash.now[:notice] = "Could not save your discussion! " \
                           "Please make sure all required fields are filled in."
      render template: "exchanges/new"
    end
  end

  def edit
    super
  end

  def update
    super
  end

  def follow
    DiscussionRelationship.define(current_user, @exchange, following: true)
    redirect_to discussion_url(@exchange, page: params[:page])
  end

  def unfollow
    DiscussionRelationship.define(current_user, @exchange, following: false)
    redirect_to discussions_url
  end

  def favorite
    DiscussionRelationship.define(current_user, @exchange, favorite: true)
    redirect_to discussion_url(@exchange, page: params[:page])
  end

  def unfavorite
    DiscussionRelationship.define(current_user, @exchange, favorite: false)
    redirect_to discussions_url
  end

  def hide
    DiscussionRelationship.define(current_user, @exchange, hidden: true)
    redirect_to discussions_url
  end

  def unhide
    DiscussionRelationship.define(current_user, @exchange, hidden: false)
    redirect_to discussion_url(@exchange, page: params[:page])
  end

  private

  def trusted_exchange_params
    return [] unless current_user.trusted?
    [:trusted]
  end

  def moderator_exchange_params
    return [] unless current_user.moderator?
    [:sticky]
  end

  def exchange_params
    params.require(:discussion).permit(
      [:title, :body, :format, :nsfw, :closed] +
        trusted_exchange_params +
        moderator_exchange_params
    )
  end

  def find_exchange
    @exchange = Exchange.find(params[:id])

    unless @exchange.is_a?(Discussion)
      redirect_to @exchange
      return
    end

    render_error 403 unless @exchange.viewable_by?(current_user)
  end
end
