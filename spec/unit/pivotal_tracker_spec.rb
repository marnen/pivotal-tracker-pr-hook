require File.expand_path '../../spec_helper', __FILE__
require_relative '../../models/pivotal_tracker'

describe PivotalTracker do
  describe 'constructor' do
    it 'takes a hash' do
      expect(PivotalTracker.new a: 1).to be_a_kind_of PivotalTracker
    end
  end

  context 'requests' do
    let(:api_token) { ENV['PIVOTAL_TRACKER_API_TOKEN'] }

    describe '.story' do
      let(:request!) { PivotalTracker.story story_id }
      let(:story_id) { rand 1_000_000..1_000_000_000 }
      let!(:story_request) { stub_request :get, URI.join(PivotalTracker::BASE_URL, "/stories/#{story_id}") }


      it 'requests the Tracker data for the given story ID' do
        request!
        expect(story_request).to have_been_made
      end

      it 'uses standard headers in the request' do
        request!
        expect(story_request.with headers: {'Content-Type' => 'application/json', 'X-TrackerToken' => api_token}).to have_been_made
      end

      it 'returns the response body parsed as JSON' do
        story_request.to_return body: '{"foo": 1, "bar": "baz"}', headers: {'Content-Type' => 'application/json'}
        expect(request!).to be == {'foo' => 1, 'bar' => 'baz'}
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
        post!
        expect(tracker_request.with headers: {'X-TrackerToken' => api_token}).to have_been_requested
      end
    end
  end
end
