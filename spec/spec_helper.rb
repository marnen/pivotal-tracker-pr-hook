require 'rack/test'
require 'rspec'
require 'webmock/rspec'

require File.expand_path '../../hook', __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }
