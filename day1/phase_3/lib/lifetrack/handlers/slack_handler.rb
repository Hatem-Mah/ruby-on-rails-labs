# frozen_string_literal: true

require_relative 'base_handler'

module LifeTrack
  module Handlers
    # A creative simulation of a Slack Notification Handler that format-matches
    # Slack's Block Kit JSON payloads and prints a simulated Slack notification bubble.
    class SlackHandler < BaseHandler
      # Creative coding style: using data attributes and functional transformations
      attr_reader :webhook_url, :channel

      def initialize(webhook_url: 'https://example.com/mock-slack-webhook', channel: '#lifetrack-activity')
        @webhook_url = webhook_url
        @channel = channel
      end

      def handle(event)
        case event
        in { type:, description:, duration:, timestamp: }
          payload = build_slack_block_kit(type, description, duration, event.formatted_timestamp)
          render_slack_notification_bubble(payload)
        else
          raise Errors::InterfaceViolationError, "Invalid event passed to Slack handler"
        end
      end

      private

      def build_slack_block_kit(type, description, duration, time_str)
        emoji = case type
                when :WORK then "💼"
                when :STUDY then "📖"
                when :EXERCISE then "🏋️"
                when :MEAL then "🍎"
                else "🔹"
                end

        {
          channel: @channel,
          username: "LifeTrack Bot",
          icon_emoji: ":stopwatch:",
          blocks: [
            {
              type: "header",
              text: {
                type: "plain_text",
                text: "New Activity Logged! #{emoji}",
                emoji: true
              }
            },
            {
              type: "section",
              fields: [
                {
                  type: "mrkdwn",
                  text: "*Category:*\n#{type}"
                },
                {
                  type: "mrkdwn",
                  text: "*Duration:*\n#{duration} minutes"
                }
              ]
            },
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "*Description:*\n> #{description}"
              }
            },
            {
              type: "context",
              elements: [
                {
                  type: "mrkdwn",
                  text: "Logged at: `#{time_str}`"
                }
              ]
            }
          ]
        }
      end

      def render_slack_notification_bubble(payload)
        width = 60
        border_color = "\e[38;2;74;144;226m" # Slack blue
        slack_brand = "\e[38;2;224;17;95m"  # Slack pink/aubergine-ish
        reset = "\e[0m"
        bold = "\e[1m"
        dim = "\e[2m"

        # Dynamically determine accent color based on category field
        fields = payload[:blocks][1][:fields]
        category = fields[0][:text].split("\n").last.to_sym
        
        accent_color = case category
                       when :WORK then "\e[38;2;168;130;255m"
                       when :STUDY then "\e[38;2;74;222;128m"
                       when :EXERCISE then "\e[38;2;96;165;250m"
                       when :MEAL then "\e[38;2;251;146;60m"
                       else "\e[38;2;148;163;184m" # Slate
                       end

        accent_bar = "#{accent_color}▌#{reset}"

        puts "\n"
        puts "#{border_color}┌#{'─' * (width - 2)}┐#{reset}"
        puts "#{border_color}│#{reset}  💬 #{bold}SLACK NOTIFICATION DISPATCHED#{reset}#{' ' * (width - 40)}#{border_color}│#{reset}"
        puts "#{border_color}├#{'─' * (width - 2)}┤#{reset}"
        puts "#{border_color}│#{reset}  #{dim}Webhook:#{reset} #{webhook_url[0..35]}...#{' ' * (width - 50)}#{border_color}│#{reset}"
        puts "#{border_color}│#{reset}  #{dim}Channel:#{reset} #{payload[:channel]}#{' ' * (width - payload[:channel].length - 13)}#{border_color}│#{reset}"
        puts "#{border_color}│#{' ' * (width - 2)}│#{reset}"
        
        # Display simplified Block Kit visual representation with accent vertical bar
        header_text = payload[:blocks][0][:text][:text]
        puts "#{border_color}│#{reset}  #{accent_bar} #{bold}#{slack_brand}#{header_text}#{reset}#{' ' * (width - header_text.length - 8)}#{border_color}│#{reset}"
        
        cat_text = fields[0][:text].gsub('*', '').gsub("\n", ': ')
        dur_text = fields[1][:text].gsub('*', '').gsub("\n", ': ')
        
        puts "#{border_color}│#{reset}  #{accent_bar}   #{cat_text}#{' ' * (width - cat_text.length - 10)}#{border_color}│#{reset}"
        puts "#{border_color}│#{reset}  #{accent_bar}   #{dur_text}#{' ' * (width - dur_text.length - 10)}#{border_color}│#{reset}"
        
        desc_text = payload[:blocks][2][:text][:text].gsub('*', '').gsub("\n> ", ': "') + '"'
        puts "#{border_color}│#{reset}  #{accent_bar}   #{desc_text}#{' ' * (width - desc_text.length - 10)}#{border_color}│#{reset}"
        
        puts "#{border_color}│#{' ' * (width - 2)}│#{reset}"
        puts "#{border_color}└#{'─' * (width - 2)}┘#{reset}"
      end
    end

    # Register this handler in the Registry plugin system
    register(:slack, SlackHandler)
  end
end
