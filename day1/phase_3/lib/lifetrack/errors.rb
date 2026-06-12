# frozen_string_literal: true

module LifeTrack
  module Errors
    # Error raised when a handler does not conform to the expected interface contract.
    class InterfaceViolationError < NotImplementedError; end
  end
end
