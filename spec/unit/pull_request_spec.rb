require_relative '../spec_helper'
require_relative '../../models/pull_request'

describe PullRequest do
  describe 'constructor' do
    it 'takes a hash' do
      expect(PullRequest.new a: 1).to be_a_kind_of PullRequest
    end
  end

  describe '#story_ids' do
    let(:story_id) { random_story_id }

    subject { PullRequest.new(title: title).story_ids }

    context 'no story ID' do
      let(:title) { Faker::Lorem.sentence }

      it 'returns an empty array' do
        expect(subject).to be == []
      end
    end

    context 'story ID without #' do
      let(:title) { "[#{story_id}] Faker::Lorem.sentence" }

      it 'returns an empty array' do
        expect(subject).to be == []
      end
    end

    context 'story ID at the beginning' do
      let(:title) { "[##{story_id}] #{Faker::Lorem.sentence}" }

      it 'returns the story ID' do
        expect(subject).to be == [story_id.to_s]
      end
    end

    context 'multiple story IDs' do
      let(:story_ids) { (1..3).collect { random_story_id} }
      let(:title) { "#{ids_string} #{Faker::Lorem.sentence}" }

      context 'separate brackets' do
        let(:ids_string) { story_ids.collect {|id| "[##{id}]" }.join ' ' }

        it 'returns all the story IDs' do
          expect(subject).to match_array story_ids.collect(&:to_s)
        end
      end

      context 'same brackets' do
        let(:ids_string) { "[#{story_ids.collect {|id| "##{id}" }.join ','}]"}

        it 'returns all the story IDs' do
          expect(subject).to match_array story_ids.collect(&:to_s)
        end
      end
    end
  end

  describe '#to_comment' do
    let(:data) do
      {
        'html_url' => html_url,
        'number' => number,
        'title' => title,
        'user' => {'login' => login},
        'base' => {'label' => base_label}
      }
    end
    let(:html_url) { Faker::Internet.url }
    let(:login) { Faker::Internet.user_name }
    let(:number) { rand 1..1000 }
    let(:pull_request) { PullRequest.new data }
    let(:title) { Faker::Lorem.sentence }
    let(:base_label) { Faker::Hacker.abbreviation }

    subject { pull_request.to_comment }

    it 'converts the pull request data to a string' do
      expect(subject[:text]).to be == "#{login} created pull request [##{number}: #{title}](#{html_url}) to #{base_label} "
    end
  end
end

def random_story_id
  rand 1000_000..1_000_000_000
end
