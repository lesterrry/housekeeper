# frozen_string_literal: true

module Tools
  # Logs messages to console
  class Logger
    attr_accessor :enabled

    def initialize(enabled)
      @enabled = enabled
    end

    def log(message, indent_level: 0, force: false)
      return unless @enabled || force

      indent = '  ' * indent_level
      puts "#{indent}#{message}"
    end
  end
end
