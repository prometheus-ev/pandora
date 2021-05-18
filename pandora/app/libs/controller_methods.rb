module ControllerMethods

  # call-seq:
  #   controller.linkable_actions => anArray
  #
  # Returns all linkable actions for _controller_ (see ClassMethods.linkable_actions).
  def linkable_actions
    self.class.linkable_actions
  end

  module ClassMethods

    def action_symbols
      @action_symbols ||= action_methods.map(&:to_sym)
    end

    # call-seq:
    #   control_access(roles => actions, ...)
    #
    # Controls access to controller's actions via Role's.
    #
    # Example:
    #
    #   class TestController < ApplicationController
    #
    #     control_access [:admin, :test] => :ALL,
    #                    :user => [:foo, :bar],
    #                    :DEFAULT => :welcome
    #
    #   end
    #
    # This allows users with roles "admin" or "test" to access _all_ actions,
    # those with roles "user" to access "foo" and "bar", and, finally, everyone
    # to access the "welcome" action.
    def control_access(hash)
      @access_control, @allowed_actions, access = {}, Hash.new([]), Hash.new([])

      hash.each { |roles, actions|
        roles, actions = Array(roles), Array(actions)

        roles.map!(&:to_sym)
        actions.map!(&:to_sym)
        actions = action_symbols if actions.include?(:ALL)

        actions.each { |action| access[action] |= roles }
        roles.each { |role| @allowed_actions[role] |= actions }
      }

      access.each { |action, roles|
        @access_control[action] = roles.include?(:DEFAULT) ? 'true' : roles.join('|')
      }

      before_action :control_access
    end

    def access_control(action)
      if @access_control
        @access_control[action.to_sym] || @access_control[:DEFAULT]
      end
    end

    # call-seq:
    #   allowed_actions_for(role) => anArray
    #
    # Returns all actions that are allowed for +role+.
    def allowed_actions_for(role)
      if @allowed_actions
        @allowed_actions[role.to_sym] | @allowed_actions[:DEFAULT]
      else
        action_symbols
      end
    end

    # call-seq:
    #   linkable_actions(*args) => anArray
    #
    # Sets or gets (depending on the presence of +args+) the linkable actions
    # for the controller.
    def linkable_actions(*args)
      @linkable_actions ||= args
    end

  end

  #############################################################################
  private
  #############################################################################

  # Callback to extend the receiving class with our ClassMethods.
  def self.included(base)
    base.extend(ClassMethods)

    # REWRITE: instead of using the hide_action functionality, just make the
    # methods protected
    # TODO: verify!
    base.send :protected, *instance_methods
    # base.hide_action(*instance_methods)
  end

end
