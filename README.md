# osu-tournament-stats

Who maintains spreadsheets manually in 2019 anyway.

### Running

This app requires a valid osu! API key to function. Set the API key in an environment variable named `OSU_API_KEY`
in the shell where you run the app.

Aside from that, normal Rails app operations:
- `bundle install`
- `rails db:create` and `rals db:migrate`
- `rail s`
- Open in browser

To add a match to the recorded stats: `rails osustats:add_match[<match_id>, <match_name>]`. `match_id` should be the
multiplayer ID of the match and `match_name` is whatever you want the match to be recorded as ("Qualifiers Round 1" etc.)

The app will fetch the match, player and beatmap details from the API and populate the database. It's currently
hardcoded for a 1v1 match structure. Tournament maps are identified as any map in the match that satisfies the following
conditions:
- Is played on Score v2
- Is played as Team Versus
- Has exactly 3 players in the lobby (2 participants + 1 referee)

Any map played in the lobby that doesn't satisfy these conditions are skipped, so just make sure you organise your
match lobbies around this fact when playing warmup maps etc. that shouldn't be accounted for in tournament statistics.
