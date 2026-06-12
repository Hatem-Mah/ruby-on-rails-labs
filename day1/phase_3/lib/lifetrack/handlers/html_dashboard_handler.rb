# frozen_string_literal: true

require 'json'
require_relative 'base_handler'

module LifeTrack
  module Handlers
    # Generates a premium, reactive HTML dashboard on every event dispatch.
    # Persists data to a JSON store so that past activities are kept.
    class HtmlDashboardHandler < BaseHandler
      attr_reader :html_path, :json_path

      def initialize(html_path: 'lifetrack_dashboard.html', json_path: 'lifetrack_data.json')
        @html_path = html_path
        @json_path = json_path
      end

      def handle(event)
        # 1. Load existing events from JSON
        events = load_events
        
        # 2. Add current event
        events << event.to_h

        # 3. Save updated events list
        save_events(events)

        # 4. Generate the dashboard HTML
        html_content = generate_html(events)
        File.write(@html_path, html_content)
      end

      private

      def load_events
        if File.exist?(@json_path)
          JSON.parse(File.read(@json_path)) rescue []
        else
          []
        end
      end

      def save_events(events)
        File.write(@json_path, JSON.pretty_generate(events))
      end

      def generate_html(events)
        # Parse hashes back into Event structures for calculations
        event_objs = events.map { |h| Event.from_h(h) }

        # Calculations
        total_sessions = event_objs.size
        total_duration = event_objs.sum(&:duration)
        avg_duration   = total_sessions.zero? ? 0 : (total_duration.to_f / total_sessions).round(1)

        # Durations by type
        durations = { WORK: 0, STUDY: 0, EXERCISE: 0, MEAL: 0 }
        counts = { WORK: 0, STUDY: 0, EXERCISE: 0, MEAL: 0 }
        
        event_objs.each do |e|
          durations[e.type] += e.duration if durations.key?(e.type)
          counts[e.type] += 1 if counts.key?(e.type)
        end

        favorite_type = counts.max_by { |_, v| v }&.first || "NONE"

        # SVG Chart Configuration
        max_duration = durations.values.max
        max_duration = 100 if max_duration.nil? || max_duration.zero?

        svg_bars = durations.map.with_index do |(type, duration), idx|
          pct = (duration.to_f / max_duration * 100).round(1)
          y_pos = 30 + (idx * 50)
          color_class = case type
                        when :WORK then "#a882ff"
                        when :STUDY then "#4ade80"
                        when :EXERCISE then "#60a5fa"
                        when :MEAL then "#fb923c"
                        else "#cbd5e1"
                        end
          
          <<-HTML
            <!-- Bar for #{type} -->
            <text x="20" y="#{y_pos + 14}" fill="#94a3b8" font-size="12" font-weight="600">#{type}</text>
            <rect x="100" y="#{y_pos}" width="300" height="18" rx="4" fill="#1e293b"/>
            <rect x="100" y="#{y_pos}" width="#{(300 * pct / 100).round}" height="18" rx="4" fill="#{color_class}">
              <animate attributeName="width" from="0" to="#{(300 * pct / 100).round}" dur="0.8s" fill="freeze" />
            </rect>
            <text x="415" y="#{y_pos + 14}" fill="#f8fafc" font-size="12" font-weight="700">#{duration} min</text>
          HTML
        end.join("\n")

        # Event table rows
        table_rows = event_objs.reverse.map do |e|
          badge_colors = case e.type
                         when :WORK then "bg-purple-500/10 text-purple-400 border-purple-500/20"
                         when :STUDY then "bg-emerald-500/10 text-emerald-400 border-emerald-500/20"
                         when :EXERCISE then "bg-blue-500/10 text-blue-400 border-blue-500/20"
                         when :MEAL then "bg-orange-500/10 text-orange-400 border-orange-500/20"
                         else "bg-slate-500/10 text-slate-400 border-slate-500/20"
                         end
          
          <<-HTML
            <tr class="border-b border-slate-800 hover:bg-slate-900/50 transition-colors duration-150">
              <td class="px-6 py-4 whitespace-nowrap text-sm text-slate-400">#{e.formatted_timestamp}</td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold border #{badge_colors}">
                  #{e.type}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-slate-200">#{e.description}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-slate-100 text-right">#{e.duration} min</td>
            </tr>
          HTML
        end.join("\n")

        # HTML Template
        <<-HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>LifeTrack Dashboard</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: {
            sans: ['Outfit', 'sans-serif'],
          },
        },
      },
    }
  </script>
  <style>
    body {
      background-color: #0f172a;
      color: #f8fafc;
    }
    .glass-card {
      background: rgba(30, 41, 59, 0.4);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border: 1px solid rgba(255, 255, 255, 0.05);
    }
    .glow-purple { box-shadow: 0 0 20px rgba(168, 130, 255, 0.15); }
    .glow-green { box-shadow: 0 0 20px rgba(74, 222, 128, 0.15); }
    .glow-blue { box-shadow: 0 0 20px rgba(96, 165, 250, 0.15); }
  </style>
</head>
<body class="min-h-screen p-8">
  <div class="max-w-6xl mx-auto space-y-8">
    
    <!-- Header -->
    <header class="flex items-center justify-between pb-6 border-b border-slate-800">
      <div>
        <h1 class="text-4xl font-extrabold tracking-tight bg-gradient-to-r from-purple-400 via-blue-400 to-emerald-400 bg-clip-text text-transparent">
          LifeTrack Dashboard
        </h1>
        <p class="text-slate-400 mt-2 text-sm md:text-base">
          Personal productivity analytics & SOLID execution logs.
        </p>
      </div>
      <div class="text-right">
        <span class="text-xs font-semibold text-slate-500 uppercase tracking-widest">Last Synced</span>
        <p class="text-slate-300 text-sm font-medium">#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}</p>
      </div>
    </header>

    <!-- Stat Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="glass-card glow-purple p-6 rounded-2xl flex flex-col justify-between">
        <span class="text-slate-400 text-sm font-semibold uppercase tracking-wider">Total Time Logged</span>
        <div class="mt-4">
          <span class="text-5xl font-black text-purple-400">#{total_duration}</span>
          <span class="text-slate-400 font-medium ml-1">minutes</span>
        </div>
        <p class="text-xs text-slate-500 mt-3">Across #{total_sessions} completed activities</p>
      </div>

      <div class="glass-card glow-green p-6 rounded-2xl flex flex-col justify-between">
        <span class="text-slate-400 text-sm font-semibold uppercase tracking-wider">Favorite Habit</span>
        <div class="mt-4">
          <span class="text-4xl font-black text-emerald-400">#{favorite_type}</span>
        </div>
        <p class="text-xs text-slate-500 mt-3">The category logged most frequently</p>
      </div>

      <div class="glass-card glow-blue p-6 rounded-2xl flex flex-col justify-between">
        <span class="text-slate-400 text-sm font-semibold uppercase tracking-wider">Avg. Session Length</span>
        <div class="mt-4">
          <span class="text-5xl font-black text-blue-400">#{avg_duration}</span>
          <span class="text-slate-400 font-medium ml-1">mins</span>
        </div>
        <p class="text-xs text-slate-500 mt-3">Average time per single log entry</p>
      </div>
    </div>

    <!-- Chart & Analytics -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- SVG Visualization -->
      <div class="glass-card lg:col-span-2 p-6 rounded-2xl">
        <h2 class="text-xl font-bold text-slate-200 mb-6">Time Distribution By Activity</h2>
        <div class="flex items-center justify-center">
          <svg width="480" height="240" viewBox="0 0 480 240" class="w-full max-w-lg">
            #{svg_bars}
          </svg>
        </div>
      </div>

      <!-- Quick Metrics -->
      <div class="glass-card p-6 rounded-2xl flex flex-col justify-between">
        <div>
          <h2 class="text-xl font-bold text-slate-200 mb-4">SOLID Principles Status</h2>
          <ul class="space-y-3">
            <li class="flex items-center space-x-2 text-sm text-slate-300">
              <span class="text-emerald-400 font-bold">✓</span>
              <span><strong>S</strong>ingle Responsibility: Handlers isolated</span>
            </li>
            <li class="flex items-center space-x-2 text-sm text-slate-300">
              <span class="text-emerald-400 font-bold">✓</span>
              <span><strong>O</strong>pen/Closed: Dynamic registries</span>
            </li>
            <li class="flex items-center space-x-2 text-sm text-slate-300">
              <span class="text-emerald-400 font-bold">✓</span>
              <span><strong>L</strong>iskov Substitution: Swappable handlers</span>
            </li>
            <li class="flex items-center space-x-2 text-sm text-slate-300">
              <span class="text-emerald-400 font-bold">✓</span>
              <span><strong>I</strong>nterface Segregation: Single method contract</span>
            </li>
            <li class="flex items-center space-x-2 text-sm text-slate-300">
              <span class="text-emerald-400 font-bold">✓</span>
              <span><strong>D</strong>ependency Inversion: Abstract resolution</span>
            </li>
          </ul>
        </div>
        <div class="pt-4 border-t border-slate-800 text-center">
          <span class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Architecture State</span>
          <p class="text-emerald-400 font-bold text-sm mt-1">100% SOLID Compliant</p>
        </div>
      </div>
    </div>

    <!-- History Table -->
    <div class="glass-card rounded-2xl overflow-hidden">
      <div class="px-6 py-5 border-b border-slate-800 flex justify-between items-center">
        <h2 class="text-xl font-bold text-slate-200">Activity Log History</h2>
        <span class="bg-slate-800 text-slate-300 px-3 py-1 rounded-full text-xs font-semibold">
          #{total_sessions} logs
        </span>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-slate-800">
          <thead class="bg-slate-900/30">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider">Timestamp</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider">Category</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider">Description</th>
              <th scope="col" class="px-6 py-3 text-right text-xs font-semibold text-slate-500 uppercase tracking-wider">Duration</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-800">
            #{table_rows.empty? ? '<tr><td colspan="4" class="px-6 py-12 text-center text-slate-500 text-sm">No activity logged yet. Start logging from CLI!</td></tr>' : table_rows}
          </tbody>
        </table>
      </div>
    </div>

  </div>
</body>
</html>
        HTML
      end
    end

    # Register this handler with the plugin system
    register(:html_dashboard, HtmlDashboardHandler)
  end
end
