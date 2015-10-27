require File.expand_path '../../spec_helper', __FILE__

def a_request_including(hash)
  a_tracker_request.with do |request|
    expect(JSON.parse(request.body)['source_commit']).to include hash
  end
end

describe 'webhook' do
  describe 'action' do
    let(:a_tracker_request) { a_request :post, tracker_endpoint }
    let(:tracker_endpoint) { 'https://www.pivotaltracker.com/services/v5/source_commits' }

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
      let(:title) { Faker::Lorem.sentence }

      before(:each) do
        expect_any_instance_of(app).to receive(:verify_signature).and_return true
        post!
      end

      it 'posts the pull request number to Pivotal Tracker as the commit ID' do
        expect(a_request_including 'commit_id' => "pulls/#{pull_number}").to have_been_made
      end

      it 'posts the pull request title to Pivotal Tracker as the commit message' do
        expect(a_request_including 'message' => "Created pull request: #{title}").to have_been_made
      end

      it 'posts the user ID to Pivotal Tracker as the author' do
        expect(a_request_including 'author' => login).to have_been_made
      end

      it 'post the URL to Pivotal Tracker' do
        expect(a_request_including 'url' => html_url).to have_been_made
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
