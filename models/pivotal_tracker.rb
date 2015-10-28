require 'json'
require 'net/http'

class PivotalTracker
  BASE_URL = URI 'https://www.pivotaltracker.com/services/v5/'

  def self.story(story_id)
    story_path = tracker_path "/stories/#{story_id}"
    get_request = Net::HTTP::Get.new story_path, headers
    start_tracker_session do |http|
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
      project_id ? self.class.tracker_path("/projects/#{project_id}/stories/#{story_id}/comments") : nil
    end.compact

    self.class.start_tracker_session do |http|
      story_paths.each do |story_path|
        post_comment = Net::HTTP::Post.new story_path, self.class.headers
        post_comment.body = @pull_request.to_comment.to_json
        puts "Path: #{story_path}, body: #{post_comment.body}"
        http.request post_comment
      end
    end
  end

  private

  class << self
    def start_tracker_session(&block)
      Net::HTTP::start BASE_URL.host, BASE_URL.port, use_ssl: BASE_URL.scheme == 'https', &block
    end

    def headers
      @headers ||= {
        'Content-Type' => 'application/json',
        'X-TrackerToken' => ENV['PIVOTAL_TRACKER_API_TOKEN']
      }
    end

    def tracker_path(path)
      "#{BASE_URL.path}/#{path}".squeeze('/')
    end
  end
end
