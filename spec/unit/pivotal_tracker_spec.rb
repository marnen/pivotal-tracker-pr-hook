require File.expand_path '../../spec_helper', __FILE__
require_relative '../../models/pivotal_tracker'

describe PivotalTracker do
  describe 'constructor' do
    it 'takes a hash' do
      expect(PivotalTracker.new a: 1).to be_a_kind_of PivotalTracker
    end
  end

  describe '#post!' do
    let(:data) { Hash[*(1..3).collect { [Faker::Lorem.words(1), Faker::Lorem.sentence] }.flatten] }
    let(:post!) { PivotalTracker.new(data).post! }
    let!(:tracker_request) { stub_request :post, tracker_endpoint }
    let(:tracker_endpoint) { PivotalTracker::TRACKER_URL }

    it "posts the object's data to Pivotal Tracker as JSON" do
      post!
      expect(tracker_request.with body: data.to_json).to have_been_requested
    end

    it "sets the request's content type to JSON" do
      post!
      expect(tracker_request.with headers: {'Content-Type' => 'application/json'}).to have_been_requested
    end

    it 'sends the Pivotal Tracker API token from the environment' do
      api_token = ENV['PIVOTAL_TRACKER_API_TOKEN']
      post!
      expect(tracker_request.with headers: {'X-TrackerToken' => api_token}).to have_been_requested
    end
  end
end
