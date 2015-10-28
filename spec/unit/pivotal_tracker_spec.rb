require File.expand_path '../../spec_helper', __FILE__
require_relative '../../models/pivotal_tracker'

describe PivotalTracker do
  describe 'constructor' do
    it 'takes a pull request' do
      expect(PivotalTracker.new PullRequest.new {}).to be_a_kind_of PivotalTracker
    end
  end

  context 'requests' do
    let(:api_token) { ENV['PIVOTAL_TRACKER_API_TOKEN'] }
    let(:standard_headers) { {'Content-Type' => 'application/json', 'X-TrackerToken' => api_token} }

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
        expect(story_request.with headers: standard_headers).to have_been_made
      end

      it 'returns the response body parsed as JSON' do
        story_request.to_return body: '{"foo": 1, "bar": "baz"}', headers: {'Content-Type' => 'application/json'}
        expect(request!).to be == {'foo' => 1, 'bar' => 'baz'}
      end
    end

    describe '#post!' do
      it 'posts the pull request as a comment to each of its stories' do
        title = Faker::Lorem.sentence
        pull_request = PullRequest.new title: title
        story_ids = (1..3).collect { rand(1000).to_s }
        project_ids = story_ids.zip (1..3).collect { rand(1000).to_s }
        project_ids.each do |story_id, project_id|
          stub_request(:get, URI.join(PivotalTracker::BASE_URL, "/stories/#{story_id}")).to_return body: {project_id: project_id}.to_json
        end
        allow(pull_request).to receive(:story_ids).and_return story_ids
        comment = {text: Faker::Lorem.sentence}
        allow(pull_request).to receive(:to_comment).and_return comment

        post_requests = project_ids.collect do |story_id, project_id|
          stub_request(:post,  "#{PivotalTracker::BASE_URL}projects/#{project_id}/stories/#{story_id}/comments").with body: comment.to_json, headers: standard_headers
        end

        PivotalTracker.new(pull_request).post!
        expect(post_requests).to all have_been_made
      end
    end
  end
end
