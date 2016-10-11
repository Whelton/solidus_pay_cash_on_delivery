Spree::Order.class_eval do
  alias_method :super_add_store_credit_payments, :add_store_credit_payments

  # Modified to update adjustment total & persist totals.
  # Piggybacking off this method as it a `before_transition` for
  # `confirm` and having difficulty in adding in a dedicated transition action
  def add_store_credit_payments
    super_add_store_credit_payments # Super

    # Before `confirm`, update & persist the order adjustment totals
    # so as to catch the `Cash on Delivery Fee` adjustment if added
    # in the PaymentCreate part, as the updater does not update totals
    # after creating payments, so it would have been missed
    updater.update_adjustment_total
    persist_totals
  end
end
