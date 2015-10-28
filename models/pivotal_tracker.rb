require 'json'
require 'net/http'

class PivotalTracker
  BASE_URL = URI 'https://www.pivotaltracker.com/services/v5/'
  TRACKER_URL = URI 'https://www.pivotaltracker.com/services/v5/source_commits'

  def self.story(story_id)
    story_path = "/stories/#{story_id}"
    get_request = Net::HTTP::Get.new "#{BASE_URL.path}/#{story_path}".squeeze('/'), headers
    Net::HTTP::start BASE_URL.host, BASE_URL.port, use_ssl: BASE_URL.scheme == 'https' do |http|
      response = http.request get_request
      response.body ? JSON.parse(response.body) : {}
    end
  end

  def initialize(pull_request)
    @pull_request = pull_request
  end

  def post!
    puts "Sending to Pivotal Tracker: #{@pull_request.title}"
    story_paths = @pull_request.story_ids.collect do |story_id|
      project_id = self.class.story(story_id)['project_id']
      project_id ? "/projects/#{project_id}/stories/#{story_id}" : nil
    end.compact

    Net::HTTP::start BASE_URL.host, BASE_URL.port, use_ssl: BASE_URL.scheme == 'https' do |http|
      story_paths.each do |story_path|
        post_comment = Net::HTTP::Post.new "#{BASE_URL.path}/#{story_path}/comments".squeeze('/'), self.class.headers
        post_comment.body = @pull_request.to_comment.to_json
        puts "Path: #{BASE_URL.path}/#{story_path}/comments"
        puts "Body: #{post_comment.body}"
        http.request post_comment
      end
    end
  end

  private

  def self.headers
    @headers ||= {
      'Content-Type' => 'application/json',
      'X-TrackerToken' => ENV['PIVOTAL_TRACKER_API_TOKEN']
    }
  end
end
