require 'sinatra'
require 'json'
require 'net/http'

TRACKER_URL = URI 'https://www.pivotaltracker.com/services/v5/source_commits'

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

    puts "Sending to Pivotal Tracker: #{post_data.inspect}"
    headers = {
      'Content-Type' => 'application/json',
      'X-TrackerToken' => ENV['PIVOTAL_TRACKER_API_TOKEN']
    }
    tracker = Net::HTTP::Post.new TRACKER_URL.path, headers
    tracker.body = post_data.to_json
    Net::HTTP::start TRACKER_URL.host, TRACKER_URL.port, use_ssl: TRACKER_URL.scheme == 'https' do |http|
      http.request tracker
    end
  end
end

def verify_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end
