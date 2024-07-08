class PaymentController < ApplicationController
  # skip_before_action :store_location
  skip_before_action :login_required
  skip_before_action :verify_authenticity_token, only: ['paypal_ipn']
  skip_parameter_encoding :paypal_ipn

  def self.initialize_me!
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

    render plain: 'OK'
  end


  private

    def paypal_ipn_verification(post_data)
      uri = URI.parse(PaymentTransaction::PP_TRANSACTION_URL)

      net = Net::HTTP.new(uri.host, uri.port)
      net.use_ssl = true
      net.start do |http|
        http.post(uri.path, "#{post_data}&cmd=_notify-validate").body
      end == 'VERIFIED'
    end

    initialize_me!
end
