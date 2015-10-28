require 'json'
require 'net/http'

class PivotalTracker
  BASE_URL = URI 'https://www.pivotaltracker.com/services/v5/'
  TRACKER_URL = URI 'https://www.pivotaltracker.com/services/v5/source_commits'

  def self.story(story_id)
    story_path = "/stories/#{story_id}"
    get_request = Net::HTTP::Get.new story_path, headers
    Net::HTTP::start BASE_URL.host, BASE_URL.port, use_ssl: BASE_URL.scheme == 'https' do |http|
      response = http.request get_request
      response.body ? JSON.parse(response.body) : {}
    end
  end

  def initialize(post_data)
    @post_data = post_data
  end

  def post!
    puts "Sending to Pivotal Tracker: #{@post_data.inspect}"

    post_request = Net::HTTP::Post.new TRACKER_URL.path, self.class.headers
    post_request.body = @post_data.to_json
    Net::HTTP::start TRACKER_URL.host, TRACKER_URL.port, use_ssl: TRACKER_URL.scheme == 'https' do |http|
      http.request post_request
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
