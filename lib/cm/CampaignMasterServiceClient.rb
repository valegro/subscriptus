#!/usr/bin/env ruby
endpoint_url = ARGV.shift
obj = ICampaignMasterService.new(endpoint_url)

# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDERR if $DEBUG

# SYNOPSIS
#   Login(parameters)
#
# ARGS
#   parameters      Login - {http://campaignmaster.com.au}Login
#
# RETURNS
#   parameters      LoginResponse - {http://campaignmaster.com.au}LoginResponse
#
parameters = nil
puts obj.login(parameters)

# SYNOPSIS
#   GetServerTime(parameters)
#
# ARGS
#   parameters      GetServerTime - {http://campaignmaster.com.au}GetServerTime
#
# RETURNS
#   parameters      GetServerTimeResponse - {http://campaignmaster.com.au}GetServerTimeResponse
#
parameters = nil
puts obj.getServerTime(parameters)

# SYNOPSIS
#   GetRecipients(parameters)
#
# ARGS
#   parameters      GetRecipients - {http://campaignmaster.com.au}GetRecipients
#
# RETURNS
#   parameters      GetRecipientsResponse - {http://campaignmaster.com.au}GetRecipientsResponse
#
parameters = nil
puts obj.getRecipients(parameters)

# SYNOPSIS
#   GetRecipientFields(parameters)
#
# ARGS
#   parameters      GetRecipientFields - {http://campaignmaster.com.au}GetRecipientFields
#
# RETURNS
#   parameters      GetRecipientFieldsResponse - {http://campaignmaster.com.au}GetRecipientFieldsResponse
#
parameters = nil
puts obj.getRecipientFields(parameters)

# SYNOPSIS
#   GetSentCampaigns(parameters)
#
# ARGS
#   parameters      GetSentCampaigns - {http://campaignmaster.com.au}GetSentCampaigns
#
# RETURNS
#   parameters      GetSentCampaignsResponse - {http://campaignmaster.com.au}GetSentCampaignsResponse
#
parameters = nil
puts obj.getSentCampaigns(parameters)

# SYNOPSIS
#   GetEmailCampaignSummary(parameters)
#
# ARGS
#   parameters      GetEmailCampaignSummary - {http://campaignmaster.com.au}GetEmailCampaignSummary
#
# RETURNS
#   parameters      GetEmailCampaignSummaryResponse - {http://campaignmaster.com.au}GetEmailCampaignSummaryResponse
#
parameters = nil
puts obj.getEmailCampaignSummary(parameters)

# SYNOPSIS
#   GetEmailCampaignSummaryByExternalId(parameters)
#
# ARGS
#   parameters      GetEmailCampaignSummaryByExternalId - {http://campaignmaster.com.au}GetEmailCampaignSummaryByExternalId
#
# RETURNS
#   parameters      GetEmailCampaignSummaryByExternalIdResponse - {http://campaignmaster.com.au}GetEmailCampaignSummaryByExternalIdResponse
#
parameters = nil
puts obj.getEmailCampaignSummaryByExternalId(parameters)

# SYNOPSIS
#   GetFaxCampaignSummary(parameters)
#
# ARGS
#   parameters      GetFaxCampaignSummary - {http://campaignmaster.com.au}GetFaxCampaignSummary
#
# RETURNS
#   parameters      GetFaxCampaignSummaryResponse - {http://campaignmaster.com.au}GetFaxCampaignSummaryResponse
#
parameters = nil
puts obj.getFaxCampaignSummary(parameters)

# SYNOPSIS
#   GetFaxCampaignSummaryByExternalId(parameters)
#
# ARGS
#   parameters      GetFaxCampaignSummaryByExternalId - {http://campaignmaster.com.au}GetFaxCampaignSummaryByExternalId
#
# RETURNS
#   parameters      GetFaxCampaignSummaryByExternalIdResponse - {http://campaignmaster.com.au}GetFaxCampaignSummaryByExternalIdResponse
#
parameters = nil
puts obj.getFaxCampaignSummaryByExternalId(parameters)

# SYNOPSIS
#   GetSMSCampaignSummary(parameters)
#
# ARGS
#   parameters      GetSMSCampaignSummary - {http://campaignmaster.com.au}GetSMSCampaignSummary
#
# RETURNS
#   parameters      GetSMSCampaignSummaryResponse - {http://campaignmaster.com.au}GetSMSCampaignSummaryResponse
#
parameters = nil
puts obj.getSMSCampaignSummary(parameters)

# SYNOPSIS
#   GetSMSCampaignSummaryByExternalId(parameters)
#
# ARGS
#   parameters      GetSMSCampaignSummaryByExternalId - {http://campaignmaster.com.au}GetSMSCampaignSummaryByExternalId
#
# RETURNS
#   parameters      GetSMSCampaignSummaryByExternalIdResponse - {http://campaignmaster.com.au}GetSMSCampaignSummaryByExternalIdResponse
#
parameters = nil
puts obj.getSMSCampaignSummaryByExternalId(parameters)

# SYNOPSIS
#   GetEmailCampaignResults(parameters)
#
# ARGS
#   parameters      GetEmailCampaignResults - {http://campaignmaster.com.au}GetEmailCampaignResults
#
# RETURNS
#   parameters      GetEmailCampaignResultsResponse - {http://campaignmaster.com.au}GetEmailCampaignResultsResponse
#
parameters = nil
puts obj.getEmailCampaignResults(parameters)

# SYNOPSIS
#   GetEmailCampaignResultsByExternalId(parameters)
#
# ARGS
#   parameters      GetEmailCampaignResultsByExternalId - {http://campaignmaster.com.au}GetEmailCampaignResultsByExternalId
#
# RETURNS
#   parameters      GetEmailCampaignResultsByExternalIdResponse - {http://campaignmaster.com.au}GetEmailCampaignResultsByExternalIdResponse
#
parameters = nil
puts obj.getEmailCampaignResultsByExternalId(parameters)

# SYNOPSIS
#   GetFaxCampaignResults(parameters)
#
# ARGS
#   parameters      GetFaxCampaignResults - {http://campaignmaster.com.au}GetFaxCampaignResults
#
# RETURNS
#   parameters      GetFaxCampaignResultsResponse - {http://campaignmaster.com.au}GetFaxCampaignResultsResponse
#
parameters = nil
puts obj.getFaxCampaignResults(parameters)

# SYNOPSIS
#   GetFaxCampaignResultsByExternalId(parameters)
#
# ARGS
#   parameters      GetFaxCampaignResultsByExternalId - {http://campaignmaster.com.au}GetFaxCampaignResultsByExternalId
#
# RETURNS
#   parameters      GetFaxCampaignResultsByExternalIdResponse - {http://campaignmaster.com.au}GetFaxCampaignResultsByExternalIdResponse
#
parameters = nil
puts obj.getFaxCampaignResultsByExternalId(parameters)

# SYNOPSIS
#   GetSMSCampaignResults(parameters)
#
# ARGS
#   parameters      GetSMSCampaignResults - {http://campaignmaster.com.au}GetSMSCampaignResults
#
# RETURNS
#   parameters      GetSMSCampaignResultsResponse - {http://campaignmaster.com.au}GetSMSCampaignResultsResponse
#
parameters = nil
puts obj.getSMSCampaignResults(parameters)

# SYNOPSIS
#   GetSMSCampaignResultsByExternalId(parameters)
#
# ARGS
#   parameters      GetSMSCampaignResultsByExternalId - {http://campaignmaster.com.au}GetSMSCampaignResultsByExternalId
#
# RETURNS
#   parameters      GetSMSCampaignResultsByExternalIdResponse - {http://campaignmaster.com.au}GetSMSCampaignResultsByExternalIdResponse
#
parameters = nil
puts obj.getSMSCampaignResultsByExternalId(parameters)

# SYNOPSIS
#   GetEmailCampaignBounces(parameters)
#
# ARGS
#   parameters      GetEmailCampaignBounces - {http://campaignmaster.com.au}GetEmailCampaignBounces
#
# RETURNS
#   parameters      GetEmailCampaignBouncesResponse - {http://campaignmaster.com.au}GetEmailCampaignBouncesResponse
#
parameters = nil
puts obj.getEmailCampaignBounces(parameters)

# SYNOPSIS
#   GetEmailCampaignBouncesByExternalId(parameters)
#
# ARGS
#   parameters      GetEmailCampaignBouncesByExternalId - {http://campaignmaster.com.au}GetEmailCampaignBouncesByExternalId
#
# RETURNS
#   parameters      GetEmailCampaignBouncesByExternalIdResponse - {http://campaignmaster.com.au}GetEmailCampaignBouncesByExternalIdResponse
#
parameters = nil
puts obj.getEmailCampaignBouncesByExternalId(parameters)

# SYNOPSIS
#   GetEmailCampaignOpens(parameters)
#
# ARGS
#   parameters      GetEmailCampaignOpens - {http://campaignmaster.com.au}GetEmailCampaignOpens
#
# RETURNS
#   parameters      GetEmailCampaignOpensResponse - {http://campaignmaster.com.au}GetEmailCampaignOpensResponse
#
parameters = nil
puts obj.getEmailCampaignOpens(parameters)

# SYNOPSIS
#   GetEmailCampaignOpensByExternalId(parameters)
#
# ARGS
#   parameters      GetEmailCampaignOpensByExternalId - {http://campaignmaster.com.au}GetEmailCampaignOpensByExternalId
#
# RETURNS
#   parameters      GetEmailCampaignOpensByExternalIdResponse - {http://campaignmaster.com.au}GetEmailCampaignOpensByExternalIdResponse
#
parameters = nil
puts obj.getEmailCampaignOpensByExternalId(parameters)

# SYNOPSIS
#   AddRecipient(parameters)
#
# ARGS
#   parameters      AddRecipient - {http://campaignmaster.com.au}AddRecipient
#
# RETURNS
#   parameters      AddRecipientResponse - {http://campaignmaster.com.au}AddRecipientResponse
#
parameters = nil
puts obj.addRecipient(parameters)


