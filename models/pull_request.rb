require 'ostruct'

class PullRequest < OpenStruct
  def story_ids
    title.scan(%r{\[.*?\]}).collect do |brackets|
      brackets.scan %r{#(\d+)}
    end.flatten
  end


  def to_comment
    {text: "#{user['login']} created pull request [##{number}: #{title}](#{html_url}) to #{base['label']} "}
  end
end
