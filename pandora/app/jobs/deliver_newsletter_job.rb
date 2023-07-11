class DeliverNewsletterJob < ApplicationJob
  queue_as :default

  def perform(email_id, user_id)
    email = Email.find(email_id)
    user = Account.find(user_id)

    email.deliver_now(user)
  end
end
