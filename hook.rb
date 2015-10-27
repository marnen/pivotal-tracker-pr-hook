require 'sinatra'
require 'json'
require_relative 'models/pivotal_tracker'

post '/hook' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
  payload = JSON.parse(payload_body)
  puts "Action: #{payload['action']}"
  if ['opened', 'reopened'].include? payload['action']
    pull_request = payload['pull_request']
    title = pull_request['title']
    commit_id = "pulls/#{pull_request['number']}"
    message = "Created pull request: #{title}"
    author = pull_request['user']['login']
    url = pull_request['html_url']
    post_data = {source_commit: {
      commit_id: commit_id, message: message, author: author, url: url
    }}
    PivotalTracker.new(post_data).post!
  end
end

def verify_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end
