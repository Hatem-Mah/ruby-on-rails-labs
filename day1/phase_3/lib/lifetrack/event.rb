# frozen_string_literal: true

require 'time'

module LifeTrack
  # Value object representing an event in the system.
  # We use Ruby 3.2+'s Data.define for clean, immutable data structures.
  Event = Data.define(:type, :description, :duration, :timestamp) do
    def initialize(type:, description:, duration:, timestamp: Time.now)
      super(
        type: type.to_s.upcase.to_sym,
        description: description.to_s.strip,
        duration: duration.to_i,
        timestamp: timestamp
      )
    end

    def formatted_timestamp
      timestamp.strftime("%Y-%m-%d %H:%M")
    end

    # Return a hash representation for serialization
    def to_h
      {
        type: type.to_s,
        description: description,
        duration: duration,
        timestamp: timestamp.iso8601
      }
    end

    # Build an Event from a hash
    def self.from_h(hash)
      new(
        type: hash["type"] || hash[:type],
        description: hash["description"] || hash[:description],
        duration: hash["duration"] || hash[:duration],
        timestamp: Time.parse(hash["timestamp"] || hash[:timestamp])
      )
    end
  end
end
