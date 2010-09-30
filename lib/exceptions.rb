module  Exceptions
  class ZeroAmount                            < StandardError; end
  class PurchaseNotSuccessful                 < StandardError; end
  class CreateRecurrentProfileNotSuccessful   < StandardError; end
  class TriggerRecurrentProfileNotSuccessful  < StandardError; end
  class RemoveRecurrentProfileNotSuccessful   < StandardError; end
  class UserInvalid                           < StandardError; end
  class UnableToGenerateRecurrentId           < StandardError; end
  class EmailDataError                        < StandardError; end
end