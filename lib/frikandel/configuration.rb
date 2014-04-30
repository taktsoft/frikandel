require 'singleton'

module Frikandel
  class Configuration
    include ::Singleton
    extend ::SingleForwardable

    attr_accessor :ttl, :max_ttl

    def_delegators :instance, :defaults!, :ttl, :ttl=, :max_ttl, :max_ttl=

    def initialize
      defaults!
    end

    def defaults!
      self.ttl = 2.hours
      self.max_ttl = 24.hours
    end
  end
end
