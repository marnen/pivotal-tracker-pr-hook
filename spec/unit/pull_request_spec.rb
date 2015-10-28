require_relative '../spec_helper'
require_relative '../../models/pull_request'

describe PullRequest do
  describe 'constructor' do
    it 'takes a hash' do
      expect(PullRequest.new a: 1).to be_a_kind_of PullRequest
    end
  end

  describe '#to_comment' do
    let(:data) do
      {
        'html_url' => html_url,
        'number' => number,
        'title' => title,
        'user' => {'login' => login}
      }
    end
    let(:html_url) { Faker::Internet.url }
    let(:login) { Faker::Internet.user_name }
    let(:number) { rand 1..1000 }
    let(:pull_request) { PullRequest.new data }
    let(:title) { Faker::Lorem.sentence }

    subject { pull_request.to_comment }

    it 'converts the pull request data to a string' do
      expect(subject[:text]).to be == "#{login} created pull request [##{number}: #{title}](#{html_url})"
    end

    it 'identifies the comment as coming from GitHub' do
      expect(subject[:commit_type]).to be == 'github'
    end
  end

  describe '#to_commit' do
    let(:data) do
      {
        'html_url' => html_url,
        'number' => number,
        'title' => title,
        'user' => {'login' => login}
      }
    end
    let(:html_url) { Faker::Internet.url }
    let(:login) { Faker::Internet.user_name }
    let(:number) { rand 1..1000 }
    let(:pull_request) { PullRequest.new data }
    let(:title) { Faker::Lorem.sentence }

    subject { pull_request.to_commit[:source_commit] }

    it 'wraps the whole thing in a source_commit key' do
      expect(pull_request.to_commit.keys).to be == [:source_commit]
    end

    it 'exports the login name as the author' do
      expect(subject[:author]).to be == login
    end

    it 'exports the number as the commit ID' do
      expect(subject[:commit_id]).to be == "pulls/#{number}"
    end

    it 'exports the title in the message field, with prefix' do
      expect(subject[:message]).to be == "Created pull request: #{title}"
    end

    it 'exports the URL' do
      expect(subject[:url]).to be == html_url
    end
  end
end
