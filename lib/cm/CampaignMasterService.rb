require 'xsd/qname'

# {http://campaignmaster.com.au}cmLoginToken
#   tokenString - SOAP::SOAPString
#   minutesTillTokenExpires - SOAP::SOAPLong
class CmLoginToken
  attr_accessor :tokenString
  attr_accessor :minutesTillTokenExpires

  def initialize(tokenString = nil, minutesTillTokenExpires = nil)
    @tokenString = tokenString
    @minutesTillTokenExpires = minutesTillTokenExpires
  end
end

# {http://campaignmaster.com.au}ArrayOfCmCriterion
class ArrayOfCmCriterion < ::Array
end

# {http://campaignmaster.com.au}cmCriterion
#   fieldName - SOAP::SOAPString
#   leftParentheses - SOAP::SOAPInt
#   logicalOperator - LogicalOperator
#   operand - SOAP::SOAPString
#   operator - CmBooleanBinaryOperator
#   order - SOAP::SOAPInt
#   rightParentheses - SOAP::SOAPInt
class CmCriterion
  attr_accessor :fieldName
  attr_accessor :leftParentheses
  attr_accessor :logicalOperator
  attr_accessor :operand
  attr_accessor :operator
  attr_accessor :order
  attr_accessor :rightParentheses

  def initialize(fieldName = nil, leftParentheses = nil, logicalOperator = nil, operand = nil, operator = nil, order = nil, rightParentheses = nil)
    @fieldName = fieldName
    @leftParentheses = leftParentheses
    @logicalOperator = logicalOperator
    @operand = operand
    @operator = operator
    @order = order
    @rightParentheses = rightParentheses
  end
end

# {http://campaignmaster.com.au}cmBasePaged
#   currentPage - SOAP::SOAPInt
#   isLastPage - SOAP::SOAPBoolean
class CmBasePaged
  attr_accessor :currentPage
  attr_accessor :isLastPage

  def initialize(currentPage = nil, isLastPage = nil)
    @currentPage = currentPage
    @isLastPage = isLastPage
  end
end

# {http://campaignmaster.com.au}cmPagedRecipientsResponse
#   currentPage - SOAP::SOAPInt
#   isLastPage - SOAP::SOAPBoolean
#   recipients - ArrayOfCmRecipient
class CmPagedRecipientsResponse < CmBasePaged
  attr_accessor :currentPage
  attr_accessor :isLastPage
  attr_accessor :recipients

  def initialize(currentPage = nil, isLastPage = nil, recipients = nil)
    @currentPage = currentPage
    @isLastPage = isLastPage
    @recipients = recipients
  end
end

# {http://campaignmaster.com.au}cmPagedCampaignResultsOfEmailCampaignResultRow
#   currentPage - SOAP::SOAPInt
#   isLastPage - SOAP::SOAPBoolean
#   resultRows - ArrayOfEmailCampaignResultRow
class CmPagedCampaignResultsOfEmailCampaignResultRow < CmBasePaged
  attr_accessor :currentPage
  attr_accessor :isLastPage
  attr_accessor :resultRows

  def initialize(currentPage = nil, isLastPage = nil, resultRows = nil)
    @currentPage = currentPage
    @isLastPage = isLastPage
    @resultRows = resultRows
  end
end

# {http://campaignmaster.com.au}cmPagedCampaignResultsOfFaxCampaignResultRow
#   currentPage - SOAP::SOAPInt
#   isLastPage - SOAP::SOAPBoolean
#   resultRows - ArrayOfFaxCampaignResultRow
class CmPagedCampaignResultsOfFaxCampaignResultRow < CmBasePaged
  attr_accessor :currentPage
  attr_accessor :isLastPage
  attr_accessor :resultRows

  def initialize(currentPage = nil, isLastPage = nil, resultRows = nil)
    @currentPage = currentPage
    @isLastPage = isLastPage
    @resultRows = resultRows
  end
end

# {http://campaignmaster.com.au}cmPagedCampaignResultsOfSMSCampaignResultRow
#   currentPage - SOAP::SOAPInt
#   isLastPage - SOAP::SOAPBoolean
#   resultRows - ArrayOfSMSCampaignResultRow
class CmPagedCampaignResultsOfSMSCampaignResultRow < CmBasePaged
  attr_accessor :currentPage
  attr_accessor :isLastPage
  attr_accessor :resultRows

  def initialize(currentPage = nil, isLastPage = nil, resultRows = nil)
    @currentPage = currentPage
    @isLastPage = isLastPage
    @resultRows = resultRows
  end
end

# {http://campaignmaster.com.au}cmPagedCampaignBounces
#   currentPage - SOAP::SOAPInt
#   isLastPage - SOAP::SOAPBoolean
#   resultRows - ArrayOfEmailCampaignBounceRow
class CmPagedCampaignBounces < CmBasePaged
  attr_accessor :currentPage
  attr_accessor :isLastPage
  attr_accessor :resultRows

  def initialize(currentPage = nil, isLastPage = nil, resultRows = nil)
    @currentPage = currentPage
    @isLastPage = isLastPage
    @resultRows = resultRows
  end
end

# {http://campaignmaster.com.au}cmPagedCampaignOpens
#   currentPage - SOAP::SOAPInt
#   isLastPage - SOAP::SOAPBoolean
#   resultRows - ArrayOfEmailCampaignOpenRow
class CmPagedCampaignOpens < CmBasePaged
  attr_accessor :currentPage
  attr_accessor :isLastPage
  attr_accessor :resultRows

  def initialize(currentPage = nil, isLastPage = nil, resultRows = nil)
    @currentPage = currentPage
    @isLastPage = isLastPage
    @resultRows = resultRows
  end
end

# {http://campaignmaster.com.au}ArrayOfCmRecipient
class ArrayOfCmRecipient < ::Array
end

# {http://campaignmaster.com.au}cmRecipient
#   isActive - SOAP::SOAPBoolean
#   isVerified - SOAP::SOAPBoolean
#   createdFromIpAddress - SOAP::SOAPString
#   createDateTime - SOAP::SOAPDateTime
#   createdBy - SOAP::SOAPString
#   emailAddress - SOAP::SOAPString
#   emailContentType - EmailContentType
#   values - ArrayOfCmRecipientValue
#   lastModified - SOAP::SOAPDateTime
#   lastModifiedBy - SOAP::SOAPString
#   id - SOAP::SOAPInt
class CmRecipient
  attr_accessor :isActive
  attr_accessor :isVerified
  attr_accessor :createdFromIpAddress
  attr_accessor :createDateTime
  attr_accessor :createdBy
  attr_accessor :emailAddress
  attr_accessor :emailContentType
  attr_accessor :values
  attr_accessor :lastModified
  attr_accessor :lastModifiedBy
  attr_accessor :id

  def initialize(isActive = nil, isVerified = nil, createdFromIpAddress = nil, createDateTime = nil, createdBy = nil, emailAddress = nil, emailContentType = nil, values = nil, lastModified = nil, lastModifiedBy = nil, id = nil)
    @isActive = isActive
    @isVerified = isVerified
    @createdFromIpAddress = createdFromIpAddress
    @createDateTime = createDateTime
    @createdBy = createdBy
    @emailAddress = emailAddress
    @emailContentType = emailContentType
    @values = values
    @lastModified = lastModified
    @lastModifiedBy = lastModifiedBy
    @id = id
  end
end

# {http://campaignmaster.com.au}ArrayOfCmRecipientValue
class ArrayOfCmRecipientValue < ::Array
end

# {http://campaignmaster.com.au}cmRecipientValue
#   fieldId - SOAP::SOAPString
#   fieldName - SOAP::SOAPString
#   dataType - CmDataType
#   value - SOAP::SOAPString
class CmRecipientValue
  attr_accessor :fieldId
  attr_accessor :fieldName
  attr_accessor :dataType
  attr_accessor :value

  def initialize(fieldId = nil, fieldName = nil, dataType = nil, value = nil)
    @fieldId = fieldId
    @fieldName = fieldName
    @dataType = dataType
    @value = value
  end
end

# {http://campaignmaster.com.au}ArrayOfCmRecipientField
class ArrayOfCmRecipientField < ::Array
end

# {http://campaignmaster.com.au}cmRecipientField
#   allowedValues - ArrayOfCmNameValue
#   dataType - CmDataType
#   id - SOAP::SOAPString
#   isSystemField - SOAP::SOAPBoolean
#   name - SOAP::SOAPString
class CmRecipientField
  attr_accessor :allowedValues
  attr_accessor :dataType
  attr_accessor :id
  attr_accessor :isSystemField
  attr_accessor :name

  def initialize(allowedValues = nil, dataType = nil, id = nil, isSystemField = nil, name = nil)
    @allowedValues = allowedValues
    @dataType = dataType
    @id = id
    @isSystemField = isSystemField
    @name = name
  end
end

# {http://campaignmaster.com.au}ArrayOfCmNameValue
class ArrayOfCmNameValue < ::Array
end

# {http://campaignmaster.com.au}cmNameValue
#   name - SOAP::SOAPString
#   value - SOAP::SOAPString
class CmNameValue
  attr_accessor :name
  attr_accessor :value

  def initialize(name = nil, value = nil)
    @name = name
    @value = value
  end
end

# {http://campaignmaster.com.au}ArrayOfCmCampaign
class ArrayOfCmCampaign < ::Array
end

# {http://campaignmaster.com.au}cmCampaign
#   id - SOAP::SOAPInt
#   campaignType - CmCampaignType
#   description - SOAP::SOAPString
#   name - SOAP::SOAPString
#   sentDate - SOAP::SOAPDateTime
class CmCampaign
  attr_accessor :id
  attr_accessor :campaignType
  attr_accessor :description
  attr_accessor :name
  attr_accessor :sentDate

  def initialize(id = nil, campaignType = nil, description = nil, name = nil, sentDate = nil)
    @id = id
    @campaignType = campaignType
    @description = description
    @name = name
    @sentDate = sentDate
  end
end

# {http://campaignmaster.com.au}cmCampaignSummary
#   id - SOAP::SOAPInt
#   campaignType - CmCampaignType
#   completed - SOAP::SOAPDateTime
#   started - SOAP::SOAPDateTime
#   totalContacts - SOAP::SOAPInt
#   totalFailures - SOAP::SOAPInt
#   totalSelectedRecipients - SOAP::SOAPInt
#   totalUnsubscribes - SOAP::SOAPInt
class CmCampaignSummary
  attr_accessor :id
  attr_accessor :campaignType
  attr_accessor :completed
  attr_accessor :started
  attr_accessor :totalContacts
  attr_accessor :totalFailures
  attr_accessor :totalSelectedRecipients
  attr_accessor :totalUnsubscribes

  def initialize(id = nil, campaignType = nil, completed = nil, started = nil, totalContacts = nil, totalFailures = nil, totalSelectedRecipients = nil, totalUnsubscribes = nil)
    @id = id
    @campaignType = campaignType
    @completed = completed
    @started = started
    @totalContacts = totalContacts
    @totalFailures = totalFailures
    @totalSelectedRecipients = totalSelectedRecipients
    @totalUnsubscribes = totalUnsubscribes
  end
end

# {http://campaignmaster.com.au}cmEmailCampaignSummary
#   id - SOAP::SOAPInt
#   campaignType - CmCampaignType
#   completed - SOAP::SOAPDateTime
#   started - SOAP::SOAPDateTime
#   totalContacts - SOAP::SOAPInt
#   totalFailures - SOAP::SOAPInt
#   totalSelectedRecipients - SOAP::SOAPInt
#   totalUnsubscribes - SOAP::SOAPInt
#   bounces - SOAP::SOAPInt
#   forwards - CmCounterHolder
#   clicks - CmCounterHolder
#   reads - CmCounterHolder
class CmEmailCampaignSummary < CmCampaignSummary
  attr_accessor :id
  attr_accessor :campaignType
  attr_accessor :completed
  attr_accessor :started
  attr_accessor :totalContacts
  attr_accessor :totalFailures
  attr_accessor :totalSelectedRecipients
  attr_accessor :totalUnsubscribes
  attr_accessor :bounces
  attr_accessor :forwards
  attr_accessor :clicks
  attr_accessor :reads

  def initialize(id = nil, campaignType = nil, completed = nil, started = nil, totalContacts = nil, totalFailures = nil, totalSelectedRecipients = nil, totalUnsubscribes = nil, bounces = nil, forwards = nil, clicks = nil, reads = nil)
    @id = id
    @campaignType = campaignType
    @completed = completed
    @started = started
    @totalContacts = totalContacts
    @totalFailures = totalFailures
    @totalSelectedRecipients = totalSelectedRecipients
    @totalUnsubscribes = totalUnsubscribes
    @bounces = bounces
    @forwards = forwards
    @clicks = clicks
    @reads = reads
  end
end

# {http://campaignmaster.com.au}cmFaxCampaignSummary
#   id - SOAP::SOAPInt
#   campaignType - CmCampaignType
#   completed - SOAP::SOAPDateTime
#   started - SOAP::SOAPDateTime
#   totalContacts - SOAP::SOAPInt
#   totalFailures - SOAP::SOAPInt
#   totalSelectedRecipients - SOAP::SOAPInt
#   totalUnsubscribes - SOAP::SOAPInt
class CmFaxCampaignSummary < CmCampaignSummary
  attr_accessor :id
  attr_accessor :campaignType
  attr_accessor :completed
  attr_accessor :started
  attr_accessor :totalContacts
  attr_accessor :totalFailures
  attr_accessor :totalSelectedRecipients
  attr_accessor :totalUnsubscribes

  def initialize(id = nil, campaignType = nil, completed = nil, started = nil, totalContacts = nil, totalFailures = nil, totalSelectedRecipients = nil, totalUnsubscribes = nil)
    @id = id
    @campaignType = campaignType
    @completed = completed
    @started = started
    @totalContacts = totalContacts
    @totalFailures = totalFailures
    @totalSelectedRecipients = totalSelectedRecipients
    @totalUnsubscribes = totalUnsubscribes
  end
end

# {http://campaignmaster.com.au}cmSMSCampaignSummary
#   id - SOAP::SOAPInt
#   campaignType - CmCampaignType
#   completed - SOAP::SOAPDateTime
#   started - SOAP::SOAPDateTime
#   totalContacts - SOAP::SOAPInt
#   totalFailures - SOAP::SOAPInt
#   totalSelectedRecipients - SOAP::SOAPInt
#   totalUnsubscribes - SOAP::SOAPInt
#   totalReplies - SOAP::SOAPInt
class CmSMSCampaignSummary < CmCampaignSummary
  attr_accessor :id
  attr_accessor :campaignType
  attr_accessor :completed
  attr_accessor :started
  attr_accessor :totalContacts
  attr_accessor :totalFailures
  attr_accessor :totalSelectedRecipients
  attr_accessor :totalUnsubscribes
  attr_accessor :totalReplies

  def initialize(id = nil, campaignType = nil, completed = nil, started = nil, totalContacts = nil, totalFailures = nil, totalSelectedRecipients = nil, totalUnsubscribes = nil, totalReplies = nil)
    @id = id
    @campaignType = campaignType
    @completed = completed
    @started = started
    @totalContacts = totalContacts
    @totalFailures = totalFailures
    @totalSelectedRecipients = totalSelectedRecipients
    @totalUnsubscribes = totalUnsubscribes
    @totalReplies = totalReplies
  end
end

# {http://campaignmaster.com.au}cmCounterHolder
#   total - SOAP::SOAPInt
#   unique - SOAP::SOAPInt
class CmCounterHolder
  attr_accessor :total
  attr_accessor :unique

  def initialize(total = nil, unique = nil)
    @total = total
    @unique = unique
  end
end

# {http://campaignmaster.com.au}ArrayOfEmailCampaignResultRow
class ArrayOfEmailCampaignResultRow < ::Array
end

# {http://campaignmaster.com.au}DataRow
#   rowError - SOAP::SOAPString
#   itemArray - ArrayOfAnyType
class DataRow
  attr_accessor :rowError
  attr_accessor :itemArray

  def initialize(rowError = nil, itemArray = nil)
    @rowError = rowError
    @itemArray = itemArray
  end
end

# {http://campaignmaster.com.au}EmailCampaignResultRow
#   rowError - SOAP::SOAPString
#   itemArray - ArrayOfAnyType
#   recipientId - SOAP::SOAPInt
#   emailAddress - SOAP::SOAPString
#   emailContentType - SOAP::SOAPString
#   bounced - SOAP::SOAPBoolean
#   complained - SOAP::SOAPBoolean
#   clicks - SOAP::SOAPInt
#   forwards - SOAP::SOAPInt
#   reads - SOAP::SOAPInt
class EmailCampaignResultRow < DataRow
  attr_accessor :rowError
  attr_accessor :itemArray
  attr_accessor :recipientId
  attr_accessor :emailAddress
  attr_accessor :emailContentType
  attr_accessor :bounced
  attr_accessor :complained
  attr_accessor :clicks
  attr_accessor :forwards
  attr_accessor :reads

  def initialize(rowError = nil, itemArray = nil, recipientId = nil, emailAddress = nil, emailContentType = nil, bounced = nil, complained = nil, clicks = nil, forwards = nil, reads = nil)
    @rowError = rowError
    @itemArray = itemArray
    @recipientId = recipientId
    @emailAddress = emailAddress
    @emailContentType = emailContentType
    @bounced = bounced
    @complained = complained
    @clicks = clicks
    @forwards = forwards
    @reads = reads
  end
end

# {http://campaignmaster.com.au}FaxCampaignResultRow
#   rowError - SOAP::SOAPString
#   itemArray - ArrayOfAnyType
#   faxNumber - SOAP::SOAPString
#   recipientId - SOAP::SOAPString
#   sendStatus - SOAP::SOAPString
class FaxCampaignResultRow < DataRow
  attr_accessor :rowError
  attr_accessor :itemArray
  attr_accessor :faxNumber
  attr_accessor :recipientId
  attr_accessor :sendStatus

  def initialize(rowError = nil, itemArray = nil, faxNumber = nil, recipientId = nil, sendStatus = nil)
    @rowError = rowError
    @itemArray = itemArray
    @faxNumber = faxNumber
    @recipientId = recipientId
    @sendStatus = sendStatus
  end
end

# {http://campaignmaster.com.au}SMSCampaignResultRow
#   rowError - SOAP::SOAPString
#   itemArray - ArrayOfAnyType
#   mobileNumber - SOAP::SOAPString
#   recipientId - SOAP::SOAPInt
#   reply - SOAP::SOAPString
#   sendStatus - SOAP::SOAPString
class SMSCampaignResultRow < DataRow
  attr_accessor :rowError
  attr_accessor :itemArray
  attr_accessor :mobileNumber
  attr_accessor :recipientId
  attr_accessor :reply
  attr_accessor :sendStatus

  def initialize(rowError = nil, itemArray = nil, mobileNumber = nil, recipientId = nil, reply = nil, sendStatus = nil)
    @rowError = rowError
    @itemArray = itemArray
    @mobileNumber = mobileNumber
    @recipientId = recipientId
    @reply = reply
    @sendStatus = sendStatus
  end
end

# {http://campaignmaster.com.au}EmailCampaignBounceRow
#   rowError - SOAP::SOAPString
#   itemArray - ArrayOfAnyType
#   emailAddress - SOAP::SOAPString
#   bounceReason - SOAP::SOAPString
#   resent - SOAP::SOAPString
#   bounceWeight - SOAP::SOAPString
#   bounceDate - SOAP::SOAPDateTime
class EmailCampaignBounceRow < DataRow
  attr_accessor :rowError
  attr_accessor :itemArray
  attr_accessor :emailAddress
  attr_accessor :bounceReason
  attr_accessor :resent
  attr_accessor :bounceWeight
  attr_accessor :bounceDate

  def initialize(rowError = nil, itemArray = nil, emailAddress = nil, bounceReason = nil, resent = nil, bounceWeight = nil, bounceDate = nil)
    @rowError = rowError
    @itemArray = itemArray
    @emailAddress = emailAddress
    @bounceReason = bounceReason
    @resent = resent
    @bounceWeight = bounceWeight
    @bounceDate = bounceDate
  end
end

# {http://campaignmaster.com.au}EmailCampaignOpenRow
#   rowError - SOAP::SOAPString
#   itemArray - ArrayOfAnyType
#   emailAddress - SOAP::SOAPString
#   openDate - SOAP::SOAPDateTime
class EmailCampaignOpenRow < DataRow
  attr_accessor :rowError
  attr_accessor :itemArray
  attr_accessor :emailAddress
  attr_accessor :openDate

  def initialize(rowError = nil, itemArray = nil, emailAddress = nil, openDate = nil)
    @rowError = rowError
    @itemArray = itemArray
    @emailAddress = emailAddress
    @openDate = openDate
  end
end

# {http://campaignmaster.com.au}ArrayOfAnyType
class ArrayOfAnyType < ::Array
end

# {http://campaignmaster.com.au}ArrayOfFaxCampaignResultRow
class ArrayOfFaxCampaignResultRow < ::Array
end

# {http://campaignmaster.com.au}ArrayOfSMSCampaignResultRow
class ArrayOfSMSCampaignResultRow < ::Array
end

# {http://campaignmaster.com.au}ArrayOfEmailCampaignBounceRow
class ArrayOfEmailCampaignBounceRow < ::Array
end

# {http://campaignmaster.com.au}ArrayOfEmailCampaignOpenRow
class ArrayOfEmailCampaignOpenRow < ::Array
end

# {http://campaignmaster.com.au}cmServiceReturn
#   returnValue - (any)
#   callStatus - CmCallStatus
#   errorType - CmErrorType
#   message - SOAP::SOAPString
class CmServiceReturn
  attr_accessor :returnValue
  attr_accessor :callStatus
  attr_accessor :errorType
  attr_accessor :message

  def initialize(returnValue = nil, callStatus = nil, errorType = nil, message = nil)
    @returnValue = returnValue
    @callStatus = callStatus
    @errorType = errorType
    @message = message
  end
end

# {http://campaignmaster.com.au}LogicalOperator
class LogicalOperator < ::String
  And = LogicalOperator.new("And")
  Or = LogicalOperator.new("Or")
end

# {http://campaignmaster.com.au}cmBooleanBinaryOperator
class CmBooleanBinaryOperator < ::String
  Equals = CmBooleanBinaryOperator.new("Equals")
  GreaterThan = CmBooleanBinaryOperator.new("GreaterThan")
  GreaterThanEquals = CmBooleanBinaryOperator.new("GreaterThanEquals")
  LessThan = CmBooleanBinaryOperator.new("LessThan")
  LessThanEquals = CmBooleanBinaryOperator.new("LessThanEquals")
  NotEqual = CmBooleanBinaryOperator.new("NotEqual")
end

# {http://campaignmaster.com.au}EmailContentType
class EmailContentType < ::String
  HTML = EmailContentType.new("HTML")
  MultiPart = EmailContentType.new("MultiPart")
  Text = EmailContentType.new("Text")
end

# {http://campaignmaster.com.au}cmDataType
class CmDataType < ::String
  Boolean = CmDataType.new("Boolean")
  C_Integer = CmDataType.new("Integer")
  Date = CmDataType.new("Date")
  Number = CmDataType.new("Number")
  Password = CmDataType.new("Password")
  Text = CmDataType.new("Text")
end

# {http://campaignmaster.com.au}cmCampaignType
class CmCampaignType < ::String
  Email = CmCampaignType.new("Email")
  Fax = CmCampaignType.new("Fax")
  SMS = CmCampaignType.new("SMS")
end

# {http://campaignmaster.com.au}cmOperationType
class CmOperationType < ::String
  Insert = CmOperationType.new("Insert")
  InsertOrUpdate = CmOperationType.new("InsertOrUpdate")
  Update = CmOperationType.new("Update")
end

# {http://campaignmaster.com.au}cmCallStatus
class CmCallStatus < ::String
  Failure = CmCallStatus.new("Failure")
  Success = CmCallStatus.new("Success")
end

# {http://campaignmaster.com.au}cmErrorType
class CmErrorType < ::String
  Application = CmErrorType.new("Application")
  None = CmErrorType.new("None")
  System = CmErrorType.new("System")
end

# {http://campaignmaster.com.au}Login
#   clientID - SOAP::SOAPInt
#   userName - SOAP::SOAPString
#   password - SOAP::SOAPString
class Login
  attr_accessor :clientID
  attr_accessor :userName
  attr_accessor :password

  def initialize(clientID = nil, userName = nil, password = nil)
    @clientID = clientID
    @userName = userName
    @password = password
  end
end

# {http://campaignmaster.com.au}LoginResponse
#   loginResult - CmLoginToken
class LoginResponse
  attr_accessor :loginResult

  def initialize(loginResult = nil)
    @loginResult = loginResult
  end
end

# {http://campaignmaster.com.au}GetServerTime
class GetServerTime
  def initialize
  end
end

# {http://campaignmaster.com.au}GetServerTimeResponse
#   getServerTimeResult - SOAP::SOAPDateTime
class GetServerTimeResponse
  attr_accessor :getServerTimeResult

  def initialize(getServerTimeResult = nil)
    @getServerTimeResult = getServerTimeResult
  end
end

# {http://campaignmaster.com.au}GetRecipients
#   token - SOAP::SOAPString
#   page - SOAP::SOAPInt
#   criteria - ArrayOfCmCriterion
class GetRecipients
  attr_accessor :token
  attr_accessor :page
  attr_accessor :criteria

  def initialize(token = nil, page = nil, criteria = nil)
    @token = token
    @page = page
    @criteria = criteria
  end
end

# {http://campaignmaster.com.au}GetRecipientsResponse
#   getRecipientsResult - CmPagedRecipientsResponse
class GetRecipientsResponse
  attr_accessor :getRecipientsResult

  def initialize(getRecipientsResult = nil)
    @getRecipientsResult = getRecipientsResult
  end
end

# {http://campaignmaster.com.au}GetRecipientFields
#   token - SOAP::SOAPString
class GetRecipientFields
  attr_accessor :token

  def initialize(token = nil)
    @token = token
  end
end

# {http://campaignmaster.com.au}GetRecipientFieldsResponse
#   getRecipientFieldsResult - ArrayOfCmRecipientField
class GetRecipientFieldsResponse
  attr_accessor :getRecipientFieldsResult

  def initialize(getRecipientFieldsResult = nil)
    @getRecipientFieldsResult = getRecipientFieldsResult
  end
end

# {http://campaignmaster.com.au}GetSentCampaigns
#   token - SOAP::SOAPString
#   from - SOAP::SOAPDateTime
#   to - SOAP::SOAPDateTime
class GetSentCampaigns
  attr_accessor :token
  attr_accessor :from
  attr_accessor :to

  def initialize(token = nil, from = nil, to = nil)
    @token = token
    @from = from
    @to = to
  end
end

# {http://campaignmaster.com.au}GetSentCampaignsResponse
#   getSentCampaignsResult - ArrayOfCmCampaign
class GetSentCampaignsResponse
  attr_accessor :getSentCampaignsResult

  def initialize(getSentCampaignsResult = nil)
    @getSentCampaignsResult = getSentCampaignsResult
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignSummary
#   token - SOAP::SOAPString
#   campaignId - SOAP::SOAPInt
class GetEmailCampaignSummary
  attr_accessor :token
  attr_accessor :campaignId

  def initialize(token = nil, campaignId = nil)
    @token = token
    @campaignId = campaignId
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignSummaryResponse
#   getEmailCampaignSummaryResult - CmEmailCampaignSummary
class GetEmailCampaignSummaryResponse
  attr_accessor :getEmailCampaignSummaryResult

  def initialize(getEmailCampaignSummaryResult = nil)
    @getEmailCampaignSummaryResult = getEmailCampaignSummaryResult
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignSummaryByExternalId
#   token - SOAP::SOAPString
#   externalId - SOAP::SOAPString
class GetEmailCampaignSummaryByExternalId
  attr_accessor :token
  attr_accessor :externalId

  def initialize(token = nil, externalId = nil)
    @token = token
    @externalId = externalId
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignSummaryByExternalIdResponse
#   getEmailCampaignSummaryByExternalIdResult - CmEmailCampaignSummary
class GetEmailCampaignSummaryByExternalIdResponse
  attr_accessor :getEmailCampaignSummaryByExternalIdResult

  def initialize(getEmailCampaignSummaryByExternalIdResult = nil)
    @getEmailCampaignSummaryByExternalIdResult = getEmailCampaignSummaryByExternalIdResult
  end
end

# {http://campaignmaster.com.au}GetFaxCampaignSummary
#   token - SOAP::SOAPString
#   campaignId - SOAP::SOAPInt
class GetFaxCampaignSummary
  attr_accessor :token
  attr_accessor :campaignId

  def initialize(token = nil, campaignId = nil)
    @token = token
    @campaignId = campaignId
  end
end

# {http://campaignmaster.com.au}GetFaxCampaignSummaryResponse
#   getFaxCampaignSummaryResult - CmFaxCampaignSummary
class GetFaxCampaignSummaryResponse
  attr_accessor :getFaxCampaignSummaryResult

  def initialize(getFaxCampaignSummaryResult = nil)
    @getFaxCampaignSummaryResult = getFaxCampaignSummaryResult
  end
end

# {http://campaignmaster.com.au}GetFaxCampaignSummaryByExternalId
#   token - SOAP::SOAPString
#   externalId - SOAP::SOAPString
class GetFaxCampaignSummaryByExternalId
  attr_accessor :token
  attr_accessor :externalId

  def initialize(token = nil, externalId = nil)
    @token = token
    @externalId = externalId
  end
end

# {http://campaignmaster.com.au}GetFaxCampaignSummaryByExternalIdResponse
#   getFaxCampaignSummaryByExternalIdResult - CmFaxCampaignSummary
class GetFaxCampaignSummaryByExternalIdResponse
  attr_accessor :getFaxCampaignSummaryByExternalIdResult

  def initialize(getFaxCampaignSummaryByExternalIdResult = nil)
    @getFaxCampaignSummaryByExternalIdResult = getFaxCampaignSummaryByExternalIdResult
  end
end

# {http://campaignmaster.com.au}GetSMSCampaignSummary
#   token - SOAP::SOAPString
#   campaignId - SOAP::SOAPInt
class GetSMSCampaignSummary
  attr_accessor :token
  attr_accessor :campaignId

  def initialize(token = nil, campaignId = nil)
    @token = token
    @campaignId = campaignId
  end
end

# {http://campaignmaster.com.au}GetSMSCampaignSummaryResponse
#   getSMSCampaignSummaryResult - CmSMSCampaignSummary
class GetSMSCampaignSummaryResponse
  attr_accessor :getSMSCampaignSummaryResult

  def initialize(getSMSCampaignSummaryResult = nil)
    @getSMSCampaignSummaryResult = getSMSCampaignSummaryResult
  end
end

# {http://campaignmaster.com.au}GetSMSCampaignSummaryByExternalId
#   token - SOAP::SOAPString
#   externalId - SOAP::SOAPString
class GetSMSCampaignSummaryByExternalId
  attr_accessor :token
  attr_accessor :externalId

  def initialize(token = nil, externalId = nil)
    @token = token
    @externalId = externalId
  end
end

# {http://campaignmaster.com.au}GetSMSCampaignSummaryByExternalIdResponse
#   getSMSCampaignSummaryByExternalIdResult - CmSMSCampaignSummary
class GetSMSCampaignSummaryByExternalIdResponse
  attr_accessor :getSMSCampaignSummaryByExternalIdResult

  def initialize(getSMSCampaignSummaryByExternalIdResult = nil)
    @getSMSCampaignSummaryByExternalIdResult = getSMSCampaignSummaryByExternalIdResult
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignResults
#   token - SOAP::SOAPString
#   campaignId - SOAP::SOAPInt
#   page - SOAP::SOAPInt
#   resultsUpdatedAfter - SOAP::SOAPDateTime
class GetEmailCampaignResults
  attr_accessor :token
  attr_accessor :campaignId
  attr_accessor :page
  attr_accessor :resultsUpdatedAfter

  def initialize(token = nil, campaignId = nil, page = nil, resultsUpdatedAfter = nil)
    @token = token
    @campaignId = campaignId
    @page = page
    @resultsUpdatedAfter = resultsUpdatedAfter
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignResultsResponse
#   getEmailCampaignResultsResult - CmPagedCampaignResultsOfEmailCampaignResultRow
class GetEmailCampaignResultsResponse
  attr_accessor :getEmailCampaignResultsResult

  def initialize(getEmailCampaignResultsResult = nil)
    @getEmailCampaignResultsResult = getEmailCampaignResultsResult
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignResultsByExternalId
#   token - SOAP::SOAPString
#   externalId - SOAP::SOAPString
#   page - SOAP::SOAPInt
#   resultsUpdatedAfter - SOAP::SOAPDateTime
class GetEmailCampaignResultsByExternalId
  attr_accessor :token
  attr_accessor :externalId
  attr_accessor :page
  attr_accessor :resultsUpdatedAfter

  def initialize(token = nil, externalId = nil, page = nil, resultsUpdatedAfter = nil)
    @token = token
    @externalId = externalId
    @page = page
    @resultsUpdatedAfter = resultsUpdatedAfter
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignResultsByExternalIdResponse
#   getEmailCampaignResultsByExternalIdResult - CmPagedCampaignResultsOfEmailCampaignResultRow
class GetEmailCampaignResultsByExternalIdResponse
  attr_accessor :getEmailCampaignResultsByExternalIdResult

  def initialize(getEmailCampaignResultsByExternalIdResult = nil)
    @getEmailCampaignResultsByExternalIdResult = getEmailCampaignResultsByExternalIdResult
  end
end

# {http://campaignmaster.com.au}GetFaxCampaignResults
#   token - SOAP::SOAPString
#   campaignId - SOAP::SOAPInt
#   page - SOAP::SOAPInt
#   resultsUpdatedAfter - SOAP::SOAPDateTime
class GetFaxCampaignResults
  attr_accessor :token
  attr_accessor :campaignId
  attr_accessor :page
  attr_accessor :resultsUpdatedAfter

  def initialize(token = nil, campaignId = nil, page = nil, resultsUpdatedAfter = nil)
    @token = token
    @campaignId = campaignId
    @page = page
    @resultsUpdatedAfter = resultsUpdatedAfter
  end
end

# {http://campaignmaster.com.au}GetFaxCampaignResultsResponse
#   getFaxCampaignResultsResult - CmPagedCampaignResultsOfFaxCampaignResultRow
class GetFaxCampaignResultsResponse
  attr_accessor :getFaxCampaignResultsResult

  def initialize(getFaxCampaignResultsResult = nil)
    @getFaxCampaignResultsResult = getFaxCampaignResultsResult
  end
end

# {http://campaignmaster.com.au}GetFaxCampaignResultsByExternalId
#   token - SOAP::SOAPString
#   externalId - SOAP::SOAPString
#   page - SOAP::SOAPInt
#   resultsUpdatedAfter - SOAP::SOAPDateTime
class GetFaxCampaignResultsByExternalId
  attr_accessor :token
  attr_accessor :externalId
  attr_accessor :page
  attr_accessor :resultsUpdatedAfter

  def initialize(token = nil, externalId = nil, page = nil, resultsUpdatedAfter = nil)
    @token = token
    @externalId = externalId
    @page = page
    @resultsUpdatedAfter = resultsUpdatedAfter
  end
end

# {http://campaignmaster.com.au}GetFaxCampaignResultsByExternalIdResponse
#   getFaxCampaignResultsByExternalIdResult - CmPagedCampaignResultsOfFaxCampaignResultRow
class GetFaxCampaignResultsByExternalIdResponse
  attr_accessor :getFaxCampaignResultsByExternalIdResult

  def initialize(getFaxCampaignResultsByExternalIdResult = nil)
    @getFaxCampaignResultsByExternalIdResult = getFaxCampaignResultsByExternalIdResult
  end
end

# {http://campaignmaster.com.au}GetSMSCampaignResults
#   token - SOAP::SOAPString
#   campaignId - SOAP::SOAPInt
#   page - SOAP::SOAPInt
#   resultsUpdatedAfter - SOAP::SOAPDateTime
class GetSMSCampaignResults
  attr_accessor :token
  attr_accessor :campaignId
  attr_accessor :page
  attr_accessor :resultsUpdatedAfter

  def initialize(token = nil, campaignId = nil, page = nil, resultsUpdatedAfter = nil)
    @token = token
    @campaignId = campaignId
    @page = page
    @resultsUpdatedAfter = resultsUpdatedAfter
  end
end

# {http://campaignmaster.com.au}GetSMSCampaignResultsResponse
#   getSMSCampaignResultsResult - CmPagedCampaignResultsOfSMSCampaignResultRow
class GetSMSCampaignResultsResponse
  attr_accessor :getSMSCampaignResultsResult

  def initialize(getSMSCampaignResultsResult = nil)
    @getSMSCampaignResultsResult = getSMSCampaignResultsResult
  end
end

# {http://campaignmaster.com.au}GetSMSCampaignResultsByExternalId
#   token - SOAP::SOAPString
#   externalId - SOAP::SOAPString
#   page - SOAP::SOAPInt
#   resultsUpdatedAfter - SOAP::SOAPDateTime
class GetSMSCampaignResultsByExternalId
  attr_accessor :token
  attr_accessor :externalId
  attr_accessor :page
  attr_accessor :resultsUpdatedAfter

  def initialize(token = nil, externalId = nil, page = nil, resultsUpdatedAfter = nil)
    @token = token
    @externalId = externalId
    @page = page
    @resultsUpdatedAfter = resultsUpdatedAfter
  end
end

# {http://campaignmaster.com.au}GetSMSCampaignResultsByExternalIdResponse
#   getSMSCampaignResultsByExternalIdResult - CmPagedCampaignResultsOfSMSCampaignResultRow
class GetSMSCampaignResultsByExternalIdResponse
  attr_accessor :getSMSCampaignResultsByExternalIdResult

  def initialize(getSMSCampaignResultsByExternalIdResult = nil)
    @getSMSCampaignResultsByExternalIdResult = getSMSCampaignResultsByExternalIdResult
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignBounces
#   token - SOAP::SOAPString
#   campaignId - SOAP::SOAPInt
#   page - SOAP::SOAPInt
class GetEmailCampaignBounces
  attr_accessor :token
  attr_accessor :campaignId
  attr_accessor :page

  def initialize(token = nil, campaignId = nil, page = nil)
    @token = token
    @campaignId = campaignId
    @page = page
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignBouncesResponse
#   getEmailCampaignBouncesResult - CmPagedCampaignBounces
class GetEmailCampaignBouncesResponse
  attr_accessor :getEmailCampaignBouncesResult

  def initialize(getEmailCampaignBouncesResult = nil)
    @getEmailCampaignBouncesResult = getEmailCampaignBouncesResult
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignBouncesByExternalId
#   token - SOAP::SOAPString
#   externalId - SOAP::SOAPString
#   page - SOAP::SOAPInt
class GetEmailCampaignBouncesByExternalId
  attr_accessor :token
  attr_accessor :externalId
  attr_accessor :page

  def initialize(token = nil, externalId = nil, page = nil)
    @token = token
    @externalId = externalId
    @page = page
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignBouncesByExternalIdResponse
#   getEmailCampaignBouncesByExternalIdResult - CmPagedCampaignBounces
class GetEmailCampaignBouncesByExternalIdResponse
  attr_accessor :getEmailCampaignBouncesByExternalIdResult

  def initialize(getEmailCampaignBouncesByExternalIdResult = nil)
    @getEmailCampaignBouncesByExternalIdResult = getEmailCampaignBouncesByExternalIdResult
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignOpens
#   token - SOAP::SOAPString
#   campaignId - SOAP::SOAPInt
#   page - SOAP::SOAPInt
class GetEmailCampaignOpens
  attr_accessor :token
  attr_accessor :campaignId
  attr_accessor :page

  def initialize(token = nil, campaignId = nil, page = nil)
    @token = token
    @campaignId = campaignId
    @page = page
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignOpensResponse
#   getEmailCampaignOpensResult - CmPagedCampaignOpens
class GetEmailCampaignOpensResponse
  attr_accessor :getEmailCampaignOpensResult

  def initialize(getEmailCampaignOpensResult = nil)
    @getEmailCampaignOpensResult = getEmailCampaignOpensResult
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignOpensByExternalId
#   token - SOAP::SOAPString
#   externalId - SOAP::SOAPString
#   page - SOAP::SOAPInt
class GetEmailCampaignOpensByExternalId
  attr_accessor :token
  attr_accessor :externalId
  attr_accessor :page

  def initialize(token = nil, externalId = nil, page = nil)
    @token = token
    @externalId = externalId
    @page = page
  end
end

# {http://campaignmaster.com.au}GetEmailCampaignOpensByExternalIdResponse
#   getEmailCampaignOpensByExternalIdResult - CmPagedCampaignOpens
class GetEmailCampaignOpensByExternalIdResponse
  attr_accessor :getEmailCampaignOpensByExternalIdResult

  def initialize(getEmailCampaignOpensByExternalIdResult = nil)
    @getEmailCampaignOpensByExternalIdResult = getEmailCampaignOpensByExternalIdResult
  end
end

# {http://campaignmaster.com.au}AddRecipient
#   token - SOAP::SOAPString
#   recipientInfo - CmRecipient
#   operationType - CmOperationType
#   primaryKeyName - SOAP::SOAPString
class AddRecipient
  attr_accessor :token
  attr_accessor :recipientInfo
  attr_accessor :operationType
  attr_accessor :primaryKeyName

  def initialize(token = nil, recipientInfo = nil, operationType = nil, primaryKeyName = nil)
    @token = token
    @recipientInfo = recipientInfo
    @operationType = operationType
    @primaryKeyName = primaryKeyName
  end
end

# {http://campaignmaster.com.au}AddRecipientResponse
#   addRecipientResult - CmServiceReturn
class AddRecipientResponse
  attr_accessor :addRecipientResult

  def initialize(addRecipientResult = nil)
    @addRecipientResult = addRecipientResult
  end
end
