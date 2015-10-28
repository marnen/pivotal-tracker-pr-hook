require 'json'
require 'net/http'

class PivotalTracker
  BASE_URL = URI 'https://www.pivotaltracker.com/services/v5/'

  def self.story(story_id)
    story_path = tracker_path "/stories/#{story_id}"
    get_request = Net::HTTP::Get.new story_path, headers
    http_session do |http|
      response = http.request get_request
      response.body ? JSON.parse(response.body) : {}
    end
  end

  def initialize(pull_request)
    @pull_request = pull_request
  end

  def post!
    puts "Sending to Pivotal Tracker: #{@pull_request.title}"
    self.class.http_session do |http|
      comment_requests.each do |comment_request|
        http.request comment_request
      end
    end
  end

  private

  class << self
    def headers
      @headers ||= {
        'Content-Type' => 'application/json',
        'X-TrackerToken' => ENV['PIVOTAL_TRACKER_API_TOKEN']
      }
    end

    def http_session(&block)
      Net::HTTP::start BASE_URL.host, BASE_URL.port, use_ssl: BASE_URL.scheme == 'https', &block
    end

    def tracker_path(path)
      "#{BASE_URL.path}/#{path}".squeeze('/')
    end
  end

  def comments_path(story_id)
    project_id = self.class.story(story_id)['project_id']
    project_id ? self.class.tracker_path("/projects/#{project_id}/stories/#{story_id}/comments") : nil
  end

  def comment_requests
    story_paths = @pull_request.story_ids.collect {|id| comments_path id }.compact

    story_paths.collect do |story_path|
      Net::HTTP::Post.new(story_path, self.class.headers).tap do |post_comment|
        json = @pull_request.to_comment.to_json
        puts "Path: #{story_path}, body: #{json}"
        post_comment.body = json
      end
    end
  end
end
