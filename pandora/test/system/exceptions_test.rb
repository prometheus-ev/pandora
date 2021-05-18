require "application_system_test_case"

# can't test this at the moment because the error handlers can only be
# activated for ALL tests and that brings problems
# class ExceptionsTest < ApplicationSystemTestCase
#   test 'render custom 404' do
#     # Rails.configuration.consider_all_requests_local = false

#     login_as 'jdoe'
#     visit '/en/image/1234'
#     assert_text 'Sorry, the page you were trying to access could not be found'

#     assert_empty ActionMailer::Base.deliveries
#   end

#   test 'render custom 500' do
#     # Rails.configuration.consider_all_requests_local = false

#     login_as 'jdoe'

#     Pandora::SuperImage.stub :new, Proc.new{ 0 / 0 } do
#       visit '/en/image/5678'
#     end

#     assert_text "We're really sorry, but an error has occurred in our application"

#     mail = ActionMailer::Base.deliveries.first
#     assert_match /ZeroDivisionError/, mail.subject
#   end
# end
