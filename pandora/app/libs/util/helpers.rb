module Util

  # == Description
  #
  # Makes ActionView::Helper modules available for external use.

  module Helpers

    ActionView::Helpers.constants.each { |helper|
      const = ActionView::Helpers.const_get(helper)
      const_set(helper, Module.new { extend const }) if const.class == Module
    }

  end

end
