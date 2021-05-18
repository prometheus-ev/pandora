class PaymentTransaction < ApplicationRecord

  include Util::Config

  belongs_to :client, :class_name => 'Account', :foreign_key => 'client_id'

  PP_TRANSACTION_URL = if ENV['PM_PAYPAL_SANDBOX'] == 'true'
    "https://www.sandbox.paypal.com/cgi-bin/webscr?"
  else
    "https://www.paypal.com/cgi-bin/webscr?"
  end
  PP_SELLER_ID = ENV['PM_PAYPAL_SELLER_ID']
  CURRENCY  = 'EUR'

  validates_inclusion_of(:status,
    in: ['initialized', 'confirmed', 'succeeded', 'failed']
  )
  validates_inclusion_of :service, in: ['paypal']
  validates_presence_of :price, :status, :client_id, :service

  # receive the root url (from the controller)
  def self.root_url=(value)
    @root_url = value
  end

  def self.root_url
    @root_url
  end

  # REWRITE: use this for invoice ids in testing
  def self.generate_uuid
    self.uuids << SecureRandom.uuid
  end

  # REWRITE: to retrieve used uuids in testing
  def self.uuids
    @uuids ||= []
  end

  # def find_transaction_for(user, discount_code = nil)
  #   transaction_for(user, discount_code, false)
  # end

  def self.transaction_for(user)
    if user && (mode = user.mode.to_s) == 'paypal'
      # REWRITE: this is not possible anymore, using the new query interface
      attrs = {
        client_id: user.id,
        status: 'initialized',
        price: amount(mode, nil),
        service: mode
      }
      create(attrs)
    end
  end

  def self.amount(mode, discount_code = nil)
    {
      invoice: 45,
      single: 30,
      paypal: 30,
      nil: 30,
    }[mode.to_sym] * 100
    # License.amount(mode.to_sym, discount_code) * 100  # cents
  end

  def url
    "#{PP_TRANSACTION_URL}#{pp_query_params.to_query}"
  end

  def complete
    paypal_confirmation_mail = (service == 'paypal' && client.status == 'activated')

    if status == 'confirmed' && service == 'paypal'
      update_attributes(status: 'succeeded')
      client.paid!
      success = true
    else
      update_attributes(status: 'failed')
      success = false
    end

    client.deliver(:paypal_confirmation, success) if paypal_confirmation_mail

    success
  end

  def pp_confirm(params)
    if status == 'initialized'                   &&
        params[:payment_status] == 'Completed'   &&
        params[:mc_currency]    == CURRENCY      &&
        params[:mc_gross].to_f  == price / 100.0 &&
        params[:business]       == PP_SELLER_ID  &&
        !PaymentTransaction.exists?(:pp_transaction_id => params[:txn_id])

      self.pp_transaction_id = params[:txn_id]
      self.update_attributes(status: 'confirmed')
      true
    else
      # TODO: Is some extra logging needed here?
      update_attributes(status: 'failed')

      false
    end
  end

  alias :confirm :pp_confirm


  private

    def pp_query_params
      unless self.class.root_url
        raise Pandora::Exception, 'you have to set root_url for this class before you can use this method'
      end

      # This is set in production to reproduce the legacy behavior. In all
      # other environments we use a uuid.
      invoice_id = (Rails.env.production? ? self.id : self.class.generate_uuid)

      {
        :business      => PP_SELLER_ID,
        :cmd           => '_xclick',
        :item_name     => 'prometheus License (#%s)'.t % id,
        :amount        => price / 100.0,
        :currency_code => CURRENCY,
        :return        => "#{self.class.root_url}/account/payment_status/#{client_id}/#{id}",
        :cancel_return => "#{self.class.root_url}/license",
        :invoice       => invoice_id
      }.tap { |params|
        params[:test_ipn] = 1 if ENV['PM_PAYPAL_SANDBOX'] == 'true'
      }
    end

end
