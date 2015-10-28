require 'sinatra'
require 'json'
require_relative 'models/pivotal_tracker'
require_relative 'models/pull_request'

post '/hook' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
  payload = JSON.parse(payload_body)
  action = payload['action']
  puts "Action: #{action}"
  if ['opened', 'reopened'].include? action
    pull_request = PullRequest.new payload['pull_request']
    PivotalTracker.new(pull_request).post!
  end
end

def verify_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end
