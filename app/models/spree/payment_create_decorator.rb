Spree::PaymentCreate.class_eval do
  alias_method :super_build_source, :build_source

  # Modified to perform `create_adjustment` on payment_method if applicable,
  # also manage removing the Cash on Delivery adjustment and invalidating
  # last payments (as we'll only have one payment)
  def build_source
    # Invalidate any payment if applicable, before new payment persisted
    if payment.order.payments.present? && !['invalid', 'failed'].include?(payment.order.payments.last.state)
      payment.order.payments.last.invalidate!
    end

    # Call super
    super_build_source

    # Check if payment's order already has a cash on delivery adjustment
    # and destroy it to be sure to be sure
    payment.order.adjustments.each do |adjustment|
      if adjustment.source.present? && adjustment.source.class == Spree::CashOnDelivery::PaymentMethod
        adjustment.destroy
      end
    end

    # Check payment method exists and respnds to `create_adjustment` method
    payment_method = payment.payment_method
    if payment_method && payment_method.respond_to?(:create_adjustment)
      payment_method.create_adjustment(payment)
    end
  end

end
