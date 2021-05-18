class Settings < ApplicationRecord

  belongs_to :user, :class_name => 'Account', :foreign_key => 'user_id', required: false

  SETTINGS = content_columns.map(&:name).freeze

  LIST_SETTINGS = {
    :order     => [],
    :direction => [[SORT_DIRECTIONS, nil]],
    :per_page  => [[1..100, 10]]
  }

  SEARCH_SETTINGS = {
    :view => %w[list gallery],
    :zoom => [true, false]
  }

  def legal?(key, value)
    original, self[key] = self[key], value
    # REWRITE: we have Object#tap now
    # returning(valid?(key)) { |ok| yield self[key] if ok && block_given? }
    valid?(key).tap { |ok| yield self[key] if ok && block_given? }
  ensure
    self[key] = original if defined?(original)
  end

  class Proxy

    extend Forwardable

    def_delegators :@_default, :spec, :values_for, :default_for,
                               :include?, :valid?, :legal?, :errors, :is_a?

    attr_reader :klass, :hash

    def initialize(klass, hash = {})
      @klass, @hash, @_hash = klass, hash, hash.dup
      reload(nil, true)
    end

    alias_method :to_hash, :hash
    alias_method :save, :valid?

    def update_attribute(key, value)
      @_default[key] = value
      save.tap { |ok| hash[key.to_s] = @_default[key] if ok }
    end

    alias_method :[]=, :update_attribute

    def update_attributes(hash)
      hash.all? { |key, value| update_attribute(key, value) }
    end

    def reload(options = nil, init = false)
      @_default = klass.default

      hash.clear.merge!(@_hash) unless init
      hash.reverse_merge!(@_default)
    end

    def method_missing(method, *args, &block)
      if hash.respond_to?(method)
        hash.send(method, *args, &block)
      else
        key = method.to_s

        if setter = key.sub!(/=\z/, '')
          if respond_to?(key) || hash.respond_to?(key)
            super
          else
            update_attribute(key, *args)
          end
        else
          (errors[key.to_sym] ? @_default : hash)[key, *args]
        end
      end
    end

  end

  def self.provides_settings(hash)
    spec = HashWithIndifferentAccess.new

    hash.each { |key, values|
      default = values.first
      values, default = default if default.is_a?(Array)

      spec[key] = { :values => values, :default => default }
    }

    yield spec if block_given?

    spec.each { |key, subspec|
      values, default = subspec.values_at(:values, :default).map(&:freeze)
      # raise "setting `#{key}' has no default" if default.nil?
      next if default.nil?

      validates_inclusion_of key, :in => values

      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{key}
          value = self[:#{key}]
          return value unless value.nil?

          self[:#{key}] = #{default.inspect}
          self[:#{key}]
        end
      EOS
    }

    instance_variable_set(:@spec, spec.freeze)
    class << self; attr_reader :spec; end

    (SETTINGS - spec.keys).each { |key|
      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{key}
          raise NotImplementedError, "setting `#{key}' not available"
        end
      EOS
    }
  end

  def self.provides_list_settings(extra = {}, &block)
    provides_settings(LIST_SETTINGS.merge(extra), &block)
  end

  def self.provides_list_and_search_settings(extra = {}, &block)
    provides_list_settings(SEARCH_SETTINGS.merge(extra), &block)
  end

  def self.for(user)
    anonymous = !user || user.anonymous?

    hash = Hash.new { |h, k|
      key = "#{k}_settings"

      h[k] = if anonymous
        key.camelize.constantize.proxy(block_given? ? yield(key) : {})
      else
        user.send(key) || user.send("build_#{key}")
      end
    }

    base_class? ? hash : hash[name.underscore.sub(/_settings\z/, '')]
  end

  # REWRITE: changed, not to use 'returning' anymore
  def self.default
    new.tap do |s|
      s.readonly!
    end
  end

  def self.default_for(key)
    spec[key][:default]
  end

  def self.values_for(key)
    spec[key][:values]
  end

  def self.proxy(hash = {})
    Proxy.new(self, hash)
  end

  extend Forwardable

  def_delegators 'self.class', :spec, :values_for, :default_for

  def include?(key)
    spec.keys.include?(key.to_s)
  end

  def settings
    spec.keys.inject({}) { |h, k| h[k] = send(k); h }
  end

  alias_method :to_hash, :settings

  def merge(other)
    settings.merge(other)
  end

end
