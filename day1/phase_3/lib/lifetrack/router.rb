# frozen_string_literal: true

require_relative 'errors'
require_relative 'handlers/base_handler'

module LifeTrack
  # The central dispatching agent that registers and notifies handlers on events.
  class EventRouter
    attr_reader :handlers

    def initialize
      @handlers = []
    end

    # Dynamic DSL Configuration
    # Uses Registry lookup to support Open/Closed principle (O)
    def self.configure(&block)
      router = new
      Configurator.new(router).instance_eval(&block) if block_given?
      router
    end

    def register(handler)
      unless handler.respond_to?(:handle)
        raise Errors::InterfaceViolationError, 
              "Handler #{handler.class.name} does not implement required interface method '#handle(event)'."
      end
      @handlers << handler
    end

    def dispatch(event)
      @handlers.each do |handler|
        handler.handle(event)
      end
    end

    # Configurator block helper to execute the DSL.
    class Configurator
      def initialize(router)
        @router = router
      end

      # Dynamically lookup handlers via name and instantiate them with custom kwargs
      def use(handler_name, **options)
        handler_class = Handlers.lookup(handler_name)
        @router.register(handler_class.new(**options))
      end
    end
  end
end
