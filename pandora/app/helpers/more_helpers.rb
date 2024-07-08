module MoreHelpers
  def self.included(base)
    Dir[__FILE__.sub(/\.rb\z/, '/*_helper.rb')].each {|helper|
      base.send(:include, const_get(File.basename(helper, '.rb').classify))
    }
  end
end
