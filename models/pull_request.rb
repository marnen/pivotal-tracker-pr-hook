require 'ostruct'

class PullRequest < OpenStruct
  def story_ids
    title.scan(%r{\[.*?\]}).collect do |brackets|
      brackets.scan %r{#(\d+)}
    end.flatten
  end


  def to_commit
    {
      source_commit: {
        author: user['login'],
        commit_id: "pulls/#{number}",
        message: "Created pull request: #{title}",
        url: html_url
      }
    }
  end

  def to_comment
    {
      commit_type: 'github',
      text: "#{user['login']} created pull request [##{number}: #{title}](#{html_url})"
    }
  end
end
