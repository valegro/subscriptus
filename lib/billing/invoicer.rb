module Billing

  module Invoicer

    INITIAL_INVOICE_NUMBER = 10000
    OVERDUE_PERIOD = 14.days
    STALE_PERIOD = 14.days

    def self.config
      @@config ||= YAML.load_file(File.join(RAILS_ROOT, 'config', 'harvest.yml'))[RAILS_ENV].symbolize_keys
    end

    #Harvest = ::Harvest::Base.new(Billing::Invoicer.config)

    class HarvestInvoiceMissing < StandardError; end
    class HarvestAccountMissing < StandardError; end
    class HarvestAccountInactive < StandardError; end

    def self.included(klass)
      klass.class_eval do
        has_states :draft, :invoiced, :overdue, :stale, :paid do
          expires :invoiced => :overdue, :after => OVERDUE_PERIOD
          expires :overdue => :stale, :after => STALE_PERIOD
          on :invoice do
            transition :draft => :invoiced
          end
          on :overdue do
            transition :invoiced => :overdue
          end
          on :stale do
            transition :overdue => :stale
          end
          on :pay do
            transition :draft => :paid, :invoiced => :paid, :overdue => :paid, :stale => :paid
          end
        end
        after_enter_invoiced :mark_subscription_as_invoiced
        after_enter_overdue :communicate_overdue_invoice
        after_enter_stale :disable_stale_account
        before_enter_paid :invoice_paid
        after_enter_paid :update_paid_account
        before_create :generate_invoice_number
        before_create :create_harvest_invoice
      end
    end

    def self.next_invoice_number
      result = ActiveRecord::Base.connection.execute("select invoice_number from subscription_invoices order by invoice_number desc limit 1;")
      existing = result.try(:to_a).try(:first)
      if existing.kind_of?(Array)
        existing = existing.first
      elsif existing.kind_of?(Hash)
        existing = existing['invoice_number']
      end
      existing ? existing.to_i + 1 : INITIAL_INVOICE_NUMBER
    end

    def send_invoice!
      ApplicationError.catch! :error => ApplicationError::HARVEST do
        # This creates a harvest invoice message, that in turn, is sent to the
        # customer via the Harvest systems. Sending a message to the
        # invoice, marks the invoice as being 'sent' in their system.
        # http://www.getharvest.com/api/invoice/messages
        message = Harvest.invoice_messages.new
        message.attributes = { :invoice_id => harvest_invoice_id, :body => self.message, :recipients => subscription.account.admin.email, :attach_pdf => true }
        message.save
        message
      end
    end

    def sync_with_harvest!
      ApplicationError.catch! :error => ApplicationError::HARVEST do

        # First check to see we have a harvest invoice.
        raise HarvestInvoiceMissing unless harvest_invoice

        # If the remote invoice is paid...
        if harvest_invoice.state == "paid"
          return paid? ? true : pay! # Only attempt a pay if we have already.
        end

        # Update the amount due for partial payments.
        self.update_attribute :amount_due, harvest_invoice.due_amount.to_f

        return true

      end
    end

    private

      def mark_subscription_as_invoiced
        send_invoice!
        subscription.invoice!
      end

      def harvest_invoice
        ApplicationError.catch! :error => ApplicationError::HARVEST do
          @harvest_invoice ||= Harvest.invoices.find(self.harvest_invoice_id)
        end
      end

      def create_harvest_invoice
        client = find_harvest_client(subscription.account)

        ApplicationError.catch! :error => ApplicationError::HARVEST do

          # Create the invoice
          @harvest_invoice = Harvest.invoices.new

          line_items = <<-CSV
kind,description,quantity,unit_price,amount,taxed,taxed2,project_id
Service,#{self.subscription.name} Plan (#{self.increase_renewal_by} month subscription),1,#{self.amount},0,true,false,#{Billing::Invoicer.config['project_id']}
          CSV

          issue_date = Date.today
          @harvest_invoice.attributes = { 
            :client_id => client.id,
            :issued_at => issue_date,
            :due_at =>  issue_date + OVERDUE_PERIOD,
            :kind => :free_form,
            :number => invoice_number,
            :csv_line_items => line_items
          }

          @harvest_invoice.save

        end

        self.harvest_invoice_id = @harvest_invoice.id
      end

      def generate_invoice_number
        self.invoice_number = Billing::Invoicer.next_invoice_number
      end

      def disable_stale_account
        subscription.disable!("Invoice Overdue")
      end

      def communicate_overdue_invoice
        send_invoice! # Just resend the invoice.
      end

      def find_harvest_client(account)
        # Lookup or create a new client. Also update properties while we
        # are here.
        ApplicationError.catch! :error => ApplicationError::HARVEST do

          # If there already is a harvest client.
          if account.harvest_client_id?
            client = Harvest.clients.find(account.harvest_client_id)

            # Check for existance
            unless client
              raise HarvestAccountMissing, "Harvest client ##{account.harvest_client_id} could not be found."
            end

            # Check for active
            unless client.active
              raise HarvestAccountInactive, "Harvest client ##{account.harvest_client_id} is no longer active and cannot be invoiced."
            end
          else
            client = Harvest.clients.new
          end

          client.name = account.name
          client.save

          # Save harvest client id.
          account.update_attribute :harvest_client_id, client.id if account.harvest_client_id.nil?

          client # Returns client

        end
      end

      def invoice_paid
        # Mark the invoice as paid in harvest.
        ApplicationError.catch! :error => ApplicationError::HARVEST do
          harvest_invoice.make_payment :amount => self.amount_due
        end

        # They owe nothing..
        self.amount_due = 0
      end

      def update_paid_account
        # Increase the subscription by the amount on the invoice - this
        # stops them from gaming the system.
        subscription.advance_renewal_period_by(:months => self.increase_renewal_by)

        # Check to see if they have any outstanding invoices, if they
        # dont, activate the account, otherwise, dont disable the
        # account.
        subscription.activate! if !subscription.active? && subscription.invoices.unpaid.count == 0
      end

  end

end
