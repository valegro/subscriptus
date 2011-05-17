module  Exceptions
  class ZeroAmount                           < StandardError; end
  class PurchaseNotSuccessful                < StandardError; end
  class CreateRecurrentProfileNotSuccessful  < StandardError; end
  class TriggerRecurrentProfileNotSuccessful < StandardError; end
  class RemoveRecurrentProfileNotSuccessful  < StandardError; end
  class UserInvalid                          < StandardError; end
  class InvalidName                          < StandardError; end
  class EmailDataError                       < StandardError; end
  class CanNotBePaidFor                      < StandardError; end
  class CanNotBeCanceled                     < StandardError; end
  class PaymentFailedException               < StandardError; end
  class PaymentAlreadyProcessed              < StandardError; end
  class InvalidOffer                         < StandardError; end
  class InvalidOfferTerm                     < StandardError; end
  class PaymentTokenMissing                  < StandardError; end
  class CannotStoreCard                      < StandardError; end
  class DuplicateSubscription                < StandardError; end

  class GiftNotAvailable                     < StandardError
    def initialize(gift_id)
      @gift_id = gift_id
    end

    def message
      gift = Gift.find(@gift_id)
      "The Gift #{gift.name} is no longer available"
    rescue
      "The Gift is no longer available"
    end
  end

  module Factory
    class InvalidException < StandardError
      attr_reader :subscription, :errors
      def initialize(subscription, errors)
        @subscription = subscription
        @errors = errors
      end
    end
  end
end
