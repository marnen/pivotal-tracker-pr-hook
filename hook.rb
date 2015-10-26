require 'sinatra'
require 'json'

post '/hook' do
  payload = JSON.parse(request.body.read)
  puts "Action: #{payload['action']}"
  if ['opened', 'reopened'].include? payload['action']
    pull_request = payload['pull_request']
    title = pull_request['title']
    commit_id = "pulls/#{pull_request['number']}"
    message = "Created pull request: #{title}"
    url = pull_request['html_url']
    post_data = {commit_id: commit_id, message: message, url: url}
    puts post_data.inspect
  end
end
