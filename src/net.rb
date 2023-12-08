# frozen_string_literal: true

require 'net/ping'

# Provides method for network operations
module Net
  def self.address_alive?(address)
    pinger = Net::Ping::External.new(address)
    pinger.ping?
  end
end
