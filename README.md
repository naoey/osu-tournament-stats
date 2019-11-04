## **osu-tournament-stats**
[![Build Status](https://travis-ci.org/naoey/osu-tournament-stats.svg?branch=master)](https://travis-ci.org/naoey/osu-tournament-stats)

----

### Running

This app requires a valid osu! API key to function. Set the API key in an environment variable named `OSU_API_KEY`
in the shell where you run the app. Refer to [the example file](./.env.example) for all the environment variables used
by the application.

Aside from that, normal Rails/JS app operations:
- `bundle install`
- `rails db:create` and `rails db:migrate`
- `yarn install`
- `rail s`

Under heavy rewrite at the moment, better docs later after things are all working again...
