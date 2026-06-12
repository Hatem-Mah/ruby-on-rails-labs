# frozen_string_literal: true

require_relative 'lib/lifetrack/event'
require_relative 'lib/lifetrack/router'
require_relative 'lib/lifetrack/handlers/console_handler'
require_relative 'lib/lifetrack/handlers/file_handler'
require_relative 'lib/lifetrack/handlers/html_dashboard_handler'
require_relative 'lib/lifetrack/handlers/slack_handler'

# Configure the LifeTrack application router
ROUTER = LifeTrack::EventRouter.configure do
  use :console
  use :file, path: 'lifetrack.log'
  use :html_dashboard, html_path: 'lifetrack_dashboard.html', json_path: 'lifetrack_data.json'
  use :slack, webhook_url: 'https://example.com/mock-slack-webhook', channel: '#lifetrack-activity'
end

def clear_screen
  print "\e[H\e[2J"
end

def print_banner
  purple = "\e[38;2;168;130;255m"
  bold_purple = "\e[38;2;168;130;255;1m"
  reset = "\e[0m"
  dim = "\e[2m"

  puts "\n  #{bold_purple}❖ LIFETRACK#{reset} #{dim}• Pluggable Event Router#{reset}"
  puts "  #{purple}" + "═" * 46 + "#{reset}"
end

def prompt(message)
  print "\e[1m#{message}\e[0m "
  input = gets
  exit(0) if input.nil?
  input.chomp.strip
end

def log_session(type)
  description = prompt("Description:")
  if description.empty?
    puts "\e[31mError: Description cannot be empty.\e[0m"
    return
  end

  duration_str = prompt("Duration (minutes):")
  duration = duration_str.to_i
  if duration <= 0
    puts "\e[31mError: Duration must be a positive integer.\e[0m"
    return
  end

  event = LifeTrack::Event.new(
    type: type,
    description: description,
    duration: duration
  )

  ROUTER.dispatch(event)
end

loop do
  clear_screen
  print_banner
  puts "\n  \e[38;2;168;130;255m1.\e[0m Log a work session"
  puts "  \e[38;2;74;222;128m2.\e[0m Log a study session"
  puts "  \e[38;2;96;165;250m3.\e[0m Log an exercise session"
  puts "  \e[38;2;251;146;60m4.\e[0m Log a meal"
  puts "  \e[31m5.\e[0m Exit"
  puts "\n" + "\e[38;2;168;130;255m" + "─" * 46 + "\e[0m"

  choice = prompt("Choose an option:")

  case choice
  in "1"
    log_session(:WORK)
  in "2"
    log_session(:STUDY)
  in "3"
    log_session(:EXERCISE)
  in "4"
    log_session(:MEAL)
  in "5"
    puts "\n\e[1;32mGoodbye! Keep tracking your progress.\e[0m"
    break
  else
    puts "\n\e[31mInvalid option. Press Enter to try again...\e[0m"
    input = gets
    break if input.nil?
  end
  
  puts "\nPress Enter to continue..."
  input = gets
  break if input.nil?
end

