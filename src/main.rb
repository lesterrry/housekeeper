# frozen_string_literal: true

require 'cronitor'
require 'optparse'
require_relative 'tools'
require_relative 'net'
require_relative '../config/config'
require_relative '../config/targets'

options = {
  quiet: false,
  dead_only: false,
  dry: false
}

OptionParser.new do |opts|
  opts.banner = 'Usage: main.rb [options]'
  opts.on('-q', '--quiet', 'Disable console output') do
    options[:quiet] = true
  end
  opts.on('-D', '--dead-only', 'Only output dead targets') do
    options[:dead_only] = true
  end
  opts.on('-d', '--dry-run', 'Do not send stats to Cronitor') do
    options[:dry] = true
  end
end.parse!

Cronitor.api_key = Config::CRONITOR_API_KEY

monitor = Cronitor::Monitor.new(Config::CRONITOR_MONITOR_ID)

logger = Tools::Logger.new(!options[:quiet])

targets = Targets.constants

logger.log("Checking #{targets.count} targets...")

results = {
  dead: [],
  alive: [],
  skipped: []
}

targets.each do |i|
  target = Targets.const_get(i)

  status =
    if target[:skip]
      results[:skipped] << target
      'SKIPPED'
    elsif Net.address_alive?(target[:address])
      results[:alive] << target
      'ALIVE'
    else
      results[:dead] << target
      'DEAD'
    end

  logger.log("Target #{target[:title]} is #{status}", indent_level: 1) if !options[:dead_only] or status == 'DEAD'
end

results_message = "ALIVE: #{results[:alive].count}, DEAD: #{results[:dead].count}, SKIPPED: #{results[:skipped].count}"

logger.log('Check results:')
logger.log(results_message, indent_level: 1)

unless options[:dry]
  monitor.ping(message: results_message,
               metrics: { count: results[:alive].count,
                          error_count: results[:dead].count })
end
