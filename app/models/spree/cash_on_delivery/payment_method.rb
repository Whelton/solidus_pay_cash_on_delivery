module Spree
  module CashOnDelivery
    class PaymentMethod < Spree::PaymentMethod

      preference :charge, :float, default: 5.0

      def payment_profiles_supported?
        false # we want to show the confirm step.
      end

      def create_adjustment(payment)
        # Create the adjusment
        adjustment = Spree::Adjustment.create(
            amount: preferences[:charge].to_f,
            order: payment.order,
            adjustable: payment.order,
            source: self,
            label: "Cash On Delivery Fee"
        )

        # Add it
        payment.order.adjustments << adjustment

        # Finalize it (or the total updaters will ignore it)
        adjustment.finalize!
      end

      def authorize(*args)
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
      end

      def capture(payment, source, gateway_options)
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
      end

      def void(*args)
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
      end

      def actions
        %w{capture void}
      end

      def can_capture?(payment)
        payment.state == 'pending' || payment.state == 'checkout'
      end

      def can_void?(payment)
        payment.state != 'void'
      end

      def source_required?
        false
      end

      #def provider_class
      #  self.class
      #end

      def payment_source_class
        nil
      end

      def method_type
        'cash_on_delivery'
      end

      def auto_capture?
        true
      end

    end # PaymentMethod
  end # CashOnDelivery
end # Spree
