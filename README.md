# pivotal-tracker-pr-hook

This is a GitHub webhook that will make story comments on Pivotal Tracker when pull requests are opened (or reopened) on GitHub.

## Installation

1. Clone this repository (it's a [Sinatra](http://www.sinatrarb.com) application).
2. Host it somewhere. [Heroku](http://www.heroku.com) should be fine.
3. Set it up as a GitHub [webhook](https://developer.github.com/webhooks/creating/), with the URL of http://[my-awesome-webhost.com]/hook. Set "pull request" as the event type. Enter a random string in the "secret" field.
4. On the server, set the following environment variables:
  * `PIVOTAL_TRACKER_API_TOKEN`: your Pivotal Tracker API token
  * `SECRET_TOKEN`: the random string you entered in the "secret" field in step 3.

## Usage

Open a pull request on GitHub with a Pivotal Tracker story number in the title, and a comment will get created on the appropriate Pivotal Tracker story.

The syntax expected is the same as for the [Pivotal Tracker commit hook][commit_hook]: the commit message has to include `[#123456]` somewhere (where `123456` is the story ID). Multiple story IDs are allowed in one pull request; see the [commit hook documentation][commit_hook] for more details.

[commit_hook]: https://www.pivotaltracker.com/help/api?version=v5#Tracker_Updates_in_SCM_Post_Commit_Hooks
