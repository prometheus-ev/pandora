require 'test_helper'

class InstitutionTest < ActiveSupport::TestCase
  test 'ip range inclusion' do
    nowhere = Institution.find_by! name: 'nowhere'
    nowhere.ipranges = "10.0.50.70-10.0.50.80"

    assert nowhere.authorizes_ip?('10.0.50.75')
    assert nowhere.authorizes_ip?('10.0.50.80')
    assert nowhere.authorizes_ip?('10.0.50.70')
    assert_not nowhere.authorizes_ip?('10.0.51.1')
    assert_not nowhere.authorizes_ip?('10.0.3.75')
    assert_not nowhere.authorizes_ip?('127.0.50.75')
  end

  test 'validations' do
    institution = Institution.new
    institution.ipranges = "certainly.wrong.223.112"
    assert_not institution.valid?
    assert_equal ['is invalid'], institution.errors[:ipranges]
  end
end