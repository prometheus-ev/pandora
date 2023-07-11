class SubscriptionsController < ApplicationController
  skip_before_action :login_required
  skip_before_action :verify_account_email
  skip_before_action :verify_account_terms_accepted

  skip_before_action :verify_account_active
  skip_before_action :verify_account_not_deactivated
  skip_before_action :verify_account_signup_complete

  before_action :create_brain_buster, :only => [:subscribe_form, :unsubscribe_form]

  def subscribe_form
    user = current_user
  end

  def subscribe
    unless validate_brain_buster
      render action: 'subscribe_form'
      return
    end

    email = user_params[:email]

    if Account.subscribed?(email)
      flash.now[:notice] =
        'You are already subscribed to our newsletter.'.t + ' ' +
        'We will keep you informed about news and changes!'.t
      render action: 'subscribe_form'
      return
    end

    # returns existing user or new record
    @user = Account.subscriber_for(email)

    if @user.save
      timestamp, token = @user.token_auth
      AccountMailer.with(
        user: @user,
        timestamp: timestamp,
        token: token
      ).newsletter_subscription.deliver_now

      render action: 'subscription_sent'
    else
      render action: 'subscribe_form'
      return
    end
  end

  def confirm_subscribe
    user = Account.authenticate_from_token(params[:login], params[:timestamp], params[:token]) do |user, link_expired, matching_token|
      authenticate_from_token_warnings(user, link_expired, matching_token)
    end

    if user
      if user.newsletter?
        flash[:notice] = 'You are already subscribed to our newsletter.'.t
      else
        user.update(newsletter: true, email_verified_at: Time.now)
        flash[:notice] = 'You successfully subscribed to our newsletter.'.t
      end
    else
      flash[:warning] =
        'The confirmation link is invalid!'.t + ' ' + 'Please try again.'.t
    end

    redirect_to action: 'subscribe_form'
  end

  def unsubscribe_form
    if immediate_unsubscribe
      flash[:notice] = 'You successfully unsubscribed from our newsletter.'.t
      redirect_to action: 'subscribe_form'
    else
      @user = Account.new(email: params[:email])
    end
  end

  def unsubscribe
    unless validate_brain_buster
      render action: 'unsubscribe_form'
      return
    end

    email = user_params[:email]

    if @user = Account.find_by(email: email)
      if @user.newsletter?
        timestamp, token = @user.token_auth
        AccountMailer.with(
          user: @user,
          timestamp: timestamp,
          token: token
        ).newsletter_unsubscription.deliver_now

        render :action => 'unsubscription_sent'
        return
      else
        flash.now[:warning] = 'You are not subscribed to our newsletter.'.t
      end
    else
      flash.now[:warning] = 'No subscription by that e-mail address found!'.t
    end

    render action: 'unsubscribe_form'
  end

  def confirm_unsubscribe
    @user = Account.authenticate_from_token(params[:login], params[:timestamp], params[:token]) do |user, link_expired, matching_token|
      authenticate_from_token_warnings(user, link_expired, matching_token)
    end

    if @user
      if @user.newsletter?
        if @user.subscriber?
          @user.destroy
        else
          @user.update_attribute(:newsletter, false)
        end

        flash.now[:notice] = 'You successfully unsubscribed from our newsletter.'.t
      else
        flash[:notice] = 'You already unsubscribed from our newsletter.'.t
      end

      render action: 'subscribe_form'
    else
      flash[:warning] =
        'The confirmation link is invalid!'.t + ' ' + 'Please try again.'.t

      render action: 'unsubscribe_form'
    end
  end


  protected

    def user_params
      params.require(:user).permit(:email)
    end

    def immediate_unsubscribe
      if params[:email] && params[:token]
        if RackImages::Secret.valid?(params[:token], params[:email])
          account = Account.find_by!(email: params[:email])

          if account.subscriber?
            account.destroy
          else
            account.update_attribute(:newsletter, false)
          end
          
          return true
        end
      end

      false
    end

end
