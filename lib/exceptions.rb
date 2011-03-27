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
  class InvalidOfferTerm                     < StandardError; end

  class GiftNotAvailable                     < StandardError
    def initialize(gift_id)
      @gift_id = gift_id
    end

    def message
      gift = Gift.find(@gift_id)
      "The Gift \"#{gift.name}\" is no longer available"
    rescue
      "The Gift is no longer available"
    end
  end
end
