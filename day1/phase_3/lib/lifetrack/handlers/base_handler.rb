# frozen_string_literal: true

require_relative '../errors'

module LifeTrack
  module Handlers
    # The abstract interface for all Event Handlers.
    # Defines the interface and runtime enforcement.
    class BaseHandler
      # Every handler must implement this method
      def handle(event)
        raise Errors::InterfaceViolationError, 
              "#{self.class.name} must implement the `#handle(event)` method to conform to the Handler interface."
      end
    end

    # The registry holds mapping from symbols to handler classes.
    # This keeps EventRouter closed for modification, satisfying the Open/Closed Principle.
    @registry = {}

    def self.register(name, klass)
      @registry[name.to_sym] = klass
    end

    def self.lookup(name)
      @registry[name.to_sym] || raise(ArgumentError, "No handler registered with name: #{name}")
    end

    def self.registered_names
      @registry.keys
    end
  end
end
