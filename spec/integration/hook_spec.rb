require File.expand_path '../../spec_helper', __FILE__

def stub_json_request(method, url, with: {})
  stub_request(method, url).with do |request|
    expect(JSON.parse request.body).to include with
  end
end

describe 'webhook' do
  describe 'action' do
    let(:tracker_base_url) { 'https://www.pivotaltracker.com/services/v5/' }

    shared_examples 'opened or reopened' do
      let(:html_url) { Faker::Internet.url }
      let(:login) { Faker::Internet.user_name }
      let(:params) { {action: action, pull_request: pull_request} }
      let(:post!) { post '/hook', params.to_json, {'Content-Type' => 'application/json'} }
      let(:pull_number) { rand 1..1000 }
      let(:pull_request) do
        {
          html_url: html_url,
          number: pull_number,
          title: title,
          user: {login: login}
        }
      end
      let(:story_id) { rand 1..10000 }
      let(:title) { "[##{story_id}] #{Faker::Lorem.sentence}" }

      before(:each) do
        expect_any_instance_of(app).to receive(:verify_signature).and_return true
        allow(PivotalTracker).to receive(:story).and_return 'project_id' => rand(1..10000)
      end

      it 'posts the pull request title to Pivotal Tracker as a comment message' do
        request = stub_json_request :post, %r{^#{Regexp.escape tracker_base_url}projects/\d+/stories/\d+/comments$}, with: {'text' => "#{login} created pull request [##{pull_number}: #{title}](#{html_url})"}
        post!
        expect(request).to have_been_made
      end
    end

    context 'opened' do
      let(:action) { 'opened' }
      it_behaves_like 'opened or reopened'
    end

    context 'reopened' do
      let(:action) { 'reopened' }
      it_behaves_like 'opened or reopened'
    end

    context 'otherwise' do
      it 'does not make an HTTP request' do
        post '/hook', {action: 'closed'}
        expect(a_request :any, //).not_to have_been_made
      end
    end
  end
end
