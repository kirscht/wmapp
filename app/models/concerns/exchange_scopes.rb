module ExchangeScopes
  extend ActiveSupport::Concern
  included do
    scope :sorted, -> { order("sticky DESC, updated_at DESC") }
    scope :with_posters, -> { includes(:poster) }
    scope :for_view, -> { sorted.with_posters }
  end
end
