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
end