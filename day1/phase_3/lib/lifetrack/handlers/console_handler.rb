# frozen_string_literal: true

require_relative 'base_handler'

module LifeTrack
  module Handlers
    # Prints the logged event directly to the terminal with beautiful styling.
    class ConsoleHandler < BaseHandler
      # Color constants
      RESET = "\e[0m"
      BOLD = "\e[1m"
      DIM = "\e[2m"
      
      COLORS = {
        WORK: "\e[38;2;168;130;255m",     # Soft Purple
        STUDY: "\e[38;2;74;222;128m",      # Soft Green
        EXERCISE: "\e[38;2;96;165;250m",   # Soft Blue
        MEAL: "\e[38;2;251;146;60m"        # Soft Orange
      }.freeze

      EMOJIS = {
        WORK: "💼",
        STUDY: "📖",
        EXERCISE: "🏋️",
        MEAL: "🍎"
      }.freeze

      def handle(event)
        # Destructure the event using pattern matching (Ruby 3+)
        case event
        in { type:, description:, duration:, timestamp: }
          color = COLORS[type] || RESET
          emoji = EMOJIS[type] || "🔹"
          time_str = event.formatted_timestamp

          puts "\n#{DIM}[#{time_str}]#{RESET} #{color}#{BOLD}#{type}#{RESET} #{emoji} — #{description} #{DIM}(#{duration} min)#{RESET}"
          puts "#{color}✓ Event logged successfully.#{RESET}"
        else
          raise Errors::InterfaceViolationError, "Invalid event object passed to console handler"
        end
      end
    end

    # Register this handler with the plugin system
    register(:console, ConsoleHandler)
  end
end
