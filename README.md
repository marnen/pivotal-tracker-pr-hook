# pivotal-tracker-pr-hook

This is a GitHub webhook that will make issue comments on Pivotal Tracker when pull requests are opened (or reopened) on GitHub.

## Instructions

1. Clone this repository (it's a [Sinatra](http://www.sinatrarb.com) application).
2. Host it somewhere. [Heroku](http://www.heroku.com) should be fine.
3. Set it up as a GitHub [webhook](https://developer.github.com/webhooks/creating/), with the URL of http://[my-awesome-webhost.com]/hook. Enter a random string in the "secret" field.
4. On the server, set the following environment variables:
  * `PIVOTAL_TRACKER_API_TOKEN`: your Pivotal Tracker API token
  * `SECRET_TOKEN`: the random string you entered in the "secret" field in step 3.
