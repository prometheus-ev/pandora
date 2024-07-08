require 'test_helper'

class I18nTest < ActiveSupport::TestCase
  setup do
    I18n.locale = 'en'
  end

  test 'missing translations should raise an exception' do
    with_translations_raised do
      assert_raises Pandora::Exception do
        'peep'.t
      end
    end
  end

  test 'i18n localizations should still work (number, date etc)' do
    date = Time.mktime(2018, 6, 11).to_date
    assert_equal '2018-06-11', I18n.l(date)
  end

  test 'activerecord human names should still work' do
    assert_equal 'First name', Account.human_attribute_name(:firstname)
  end

  test 'activerecord error messages should still work' do
    assert_equal(
      'Validation failed: %{errors}',
      I18n.t('activerecord.errors.messages.record_invalid')
    )
  end

  test 'keys with % or _ should work' do
    I18n.locale = :de
    assert_equal "Willkommen, %_!", "Welcome, %_!".t
  end

  test 'i18n translation file completeness' do
    base = YAML.load_file("#{Rails.root}/config/locales/en.yml")["en"]
    stack = []

    comparator = Proc.new do |b, locale, test|
      case b
      when String then assert(test.is_a?(String), "#{locale}: expected #{stack.inspect} to be a string")
      when Hash
        assert(test.is_a?(Hash), "#{locale}: expected #{stack.inspect} to be a Hash, but its not")
        b.each do |k, v|
          stack.push k
          comparator.call(v, locale, test[k])
          stack.pop
        end
      end
    end

    (I18n.available_locales - [:en]).each do |locale|
      translation = YAML.load_file("#{Rails.root}/config/locales/#{locale}.yml")[locale.to_s]
      comparator.call(base, locale, translation)
    end
  end

  test 'legacy interpolation compatibility' do
    I18n.locale = :de

    assert_nothing_raised do
      "Please see our %{help page}% for further information.".t
    end
  end
end
