# frozen_string_literal: true

require_relative 'base_handler'

module LifeTrack
  module Handlers
    # Appends event log entries to a flat text file.
    class FileHandler < BaseHandler
      attr_reader :log_path

      def initialize(path: 'lifetrack.log')
        @log_path = path
      end

      def handle(event)
        # Use pattern matching to extract fields
        case event
        in { type:, description:, duration:, timestamp: }
          File.open(@log_path, 'a') do |file|
            file.puts "[#{event.formatted_timestamp}] #{type.to_s.upcase} — #{description} (#{duration} min)"
          end
        else
          raise Errors::InterfaceViolationError, "Invalid event object passed to file handler"
        end
      end
    end

    # Register this handler with the plugin system
    register(:file, FileHandler)
  end
end
