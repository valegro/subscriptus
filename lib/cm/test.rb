require 'rubygems'
gem 'httpclient'
gem 'soap4r'

require 'soap/wsdlDriver'
require 'CampaignMasterService'

# In production we may be able to build our own classes for the relevant data types (for sending/marshalling) and use a MappingRegistry http://dev.ctor.org/soap4r/wiki/CustomMappingWithMappingRegistry
# FOR USE WITH RAILS SEE http://dev.ctor.org/soap4r/wiki/RailsAndSoap4R


# Can also try this
# def validate_certificate(is_ok, ctx)
#     cert = ctx.current_cert
#
#         # Only check the server certificate, not the issuer.
#             unless (cert.subject.to_s == cert.issuer.to_s)
#                   is_ok &&= File.open(SERVER_PEM).read == ctx.current_cert.to_pem
#                       end
#                           is_ok
#                             end
#
# driver.options['protocol.http.ssl_config.ca_file'] = ISSUER_CA_PEM

# Hack to accept all certificates for now
def validate_certificate(is_ok, ctx)
  true
end

fact = SOAP::WSDLDriverFactory.new('http://api1.campaignmaster.com.au/v1.1/CampaignMasterService.svc?wsdl')
driver = fact.create_rpc_driver
driver.generate_explicit_type = true

driver.options['protocol.http.ssl_config.verify_callback'] = method(:validate_certificate)

p driver.public_methods.sort

result = LoginResponse.new(driver.login(:clientID => 5032, :userName => "ddraper", :password => "netfox").loginResult)

puts
token = result.loginResult.tokenString
puts token
puts result.loginResult.minutesTillTokenExpires

=begin
puts "Getting Recipient Fields"
result = driver.getRecipientFields(:token => token.to_s)
result.getRecipientFieldsResult.cmRecipientField.each do |array|
  puts array.name
end
=end

=begin
Id
EmailAddress
IsVerified
IsActive
ClientId
LastModified
LastModifiedBy
EmailContentType
CreatedBy
CreatedFromIpAddress
CreatedDateTime
BounceType
=end

arry = ArrayOfCmRecipientValue.new
mobile = CmRecipientValue.new
mobile.fieldName = 'MobileNumber'
mobile.value = '0400333444'
arry << mobile

recip = CmRecipient.new
recip.createDateTime = Time.now
recip.createdBy = 'Daniel'
recip.createdFromIpAddress = '127.0.0.1'
recip.emailAddress = 'daniel@netfox.com'
recip.emailContentType = EmailContentType::HTML
recip.id = 1
recip.isActive = true
recip.isVerified = true
recip.lastModified = Time.now
recip.lastModifiedBy = 'Daniel'
#recip.values = arry

result = driver.AddRecipient(:token => token, :recipientInfo => recip, :operationType => CmOperationType::Insert, :primaryKeyName => "EmailAddress")

p result


