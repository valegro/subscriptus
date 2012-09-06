require 'soap/rpc/driver'

class ICampaignMasterService < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "https://api1.campaignmaster.com.au/v1.1/CampaignMasterService.svc"

  Methods = [
    [ "http://campaignmaster.com.au/IAPIService/Login",
      "login",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "Login"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "LoginResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/IAPIService/GetServerTime",
      "getServerTime",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetServerTime"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetServerTimeResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetRecipients",
      "getRecipients",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetRecipients"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetRecipientsResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetRecipientFields",
      "getRecipientFields",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetRecipientFields"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetRecipientFieldsResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetSentCampaigns",
      "getSentCampaigns",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSentCampaigns"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSentCampaignsResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetEmailCampaignSummary",
      "getEmailCampaignSummary",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignSummary"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignSummaryResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetEmailCampaignSummaryByExternalId",
      "getEmailCampaignSummaryByExternalId",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignSummaryByExternalId"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignSummaryByExternalIdResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetFaxCampaignSummary",
      "getFaxCampaignSummary",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetFaxCampaignSummary"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetFaxCampaignSummaryResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetFaxCampaignSummaryByExternalId",
      "getFaxCampaignSummaryByExternalId",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetFaxCampaignSummaryByExternalId"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetFaxCampaignSummaryByExternalIdResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetSMSCampaignSummary",
      "getSMSCampaignSummary",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSMSCampaignSummary"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSMSCampaignSummaryResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetSMSCampaignSummaryByExternalId",
      "getSMSCampaignSummaryByExternalId",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSMSCampaignSummaryByExternalId"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSMSCampaignSummaryByExternalIdResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetEmailCampaignResults",
      "getEmailCampaignResults",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignResults"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignResultsResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetEmailCampaignResultsByExternalId",
      "getEmailCampaignResultsByExternalId",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignResultsByExternalId"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignResultsByExternalIdResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetFaxCampaignResults",
      "getFaxCampaignResults",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetFaxCampaignResults"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetFaxCampaignResultsResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetFaxCampaignResultsByExternalId",
      "getFaxCampaignResultsByExternalId",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetFaxCampaignResultsByExternalId"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetFaxCampaignResultsByExternalIdResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetSMSCampaignResults",
      "getSMSCampaignResults",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSMSCampaignResults"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSMSCampaignResultsResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetSMSCampaignResultsByExternalId",
      "getSMSCampaignResultsByExternalId",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSMSCampaignResultsByExternalId"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetSMSCampaignResultsByExternalIdResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetEmailCampaignBounces",
      "getEmailCampaignBounces",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignBounces"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignBouncesResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetEmailCampaignBouncesByExternalId",
      "getEmailCampaignBouncesByExternalId",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignBouncesByExternalId"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignBouncesByExternalIdResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetEmailCampaignOpens",
      "getEmailCampaignOpens",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignOpens"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignOpensResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/GetEmailCampaignOpensByExternalId",
      "getEmailCampaignOpensByExternalId",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignOpensByExternalId"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "GetEmailCampaignOpensByExternalIdResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://campaignmaster.com.au/ICampaignMasterService/AddRecipient",
      "addRecipient",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "AddRecipient"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://campaignmaster.com.au", "AddRecipientResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = CampaignMasterServiceMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = CampaignMasterServiceMappingRegistry::LiteralRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        add_document_operation(*definitions)
      else
        add_rpc_operation(*definitions)
        qname = definitions[0]
        name = definitions[2]
        if qname.name != name and qname.name.capitalize == name.capitalize
          ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
            __send__(name, *arg)
          end
        end
      end
    end
  end
end

