class PaymentController < ApplicationController

  skip_before_action :store_location
  skip_before_action :login_required
  skip_before_action :verify_authenticity_token, only: ['paypal_ipn']

  def self.initialize_me!  # :nodoc:
    control_access :DEFAULT => [:paypal_ipn]
  end

  def paypal_ipn
    if transaction = PaymentTransaction.find(params[:invoice])
      if paypal_ipn_verification(request.raw_post) && transaction.confirm(params)
        transaction.complete
      end
    # TODO: What happens if the transaction is not found? Or should it also be created here?
    # else
    end

    # REWRITE: uses a different key now
    # render :text => 'OK'
    render plain: 'OK'
  end

  #############################################################################
  private
  #############################################################################

  def paypal_ipn_verification(post_data)
    uri = URI.parse(PaymentTransaction::PP_TRANSACTION_URL)

    # REWRITE: this uses monkey patching and conflicts with Rails'
    # with_options
    net = Net::HTTP.new(uri.host, uri.port)
    net.use_ssl = true
    net.start do |http|
      http.post(uri.path, "#{post_data}&cmd=_notify-validate").body
    end == 'VERIFIED'
    # Net::HTTP.with_options(uri.host, uri.port, :use_ssl => true).start { |http|
    #   http.post(uri.path, "#{post_data}&cmd=_notify-validate").body
    # } == 'VERIFIED'
  end

###############################################################################
  initialize_me!
###############################################################################

end
