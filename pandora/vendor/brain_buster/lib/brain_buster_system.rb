module BrainBusterSystem

  def create_brain_buster(passed = captcha_passed?)
    # REWRITE: those are instance variables now
    # passed || assigns[:captcha] = BrainBuster.find_random_or_previous(
    passed || @captcha = BrainBuster.find_random_or_previous(
      params[:captcha_id] || flash[:failed_captcha],
      # REWRITE: we can simply use i18n
      # Locale.active? ? Locale.active.language.code : DEFAULT_LOCALE
      I18n.locale
    )
  end

  def validate_brain_buster
    return true if captcha_passed?
    return captcha_failure unless params[:captcha_id] && params[:captcha_answer]

    # REWRITE: instance variables now
    # captcha = assigns[:captcha] = create_brain_buster(false)
    captcha = @captcha = create_brain_buster(false)
    success = captcha.attempt?(params[:captcha_answer])

    flash.now[:failed_captcha] = success ? nil : params[:captcha_id]
    cookies[:captcha_status] = encrypt_brain_buster(success ? 'passed' : 'failed')

    success || captcha_failure
  end

  def captcha_passed?
    cookies[:captcha_status] == encrypt_brain_buster('passed')
  end

  private

  def captcha_failure
    flash.now[:warning] = 'Your captcha answer failed - please try again.'.t
    false
  end

  def encrypt_brain_buster(str)
    Digest::SHA256.hexdigest("--#{str}--#{SECRETS[:bb_salt]}--")
  end

  def self.included(base)
    base.helper_method :captcha_passed?
  end

end
