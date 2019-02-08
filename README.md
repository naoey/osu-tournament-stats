# osu-tournament-stats

### Running

This app requires a valid osu! API key to function. Set the API key in an environment variable named `OSU_API_KEY`
in the shell where you run the app.

Aside from that, normal Rails/JS app operations:
- `bundle install`
- `rails db:create` and `rals db:migrate`
- `yarn install`
- `rail s`

To add a match to the recorded stats: `rails osustats:add_match[<match_id>, <match_name>]`. `match_id` should be the
multiplayer ID of the match and `match_name` is whatever you want the match to be recorded as ("Qualifiers Round 1" etc.)

Alternatively, the `parse_scores.sh` script can be executed after setting the input path in it to a valid CSV file in the format:
```
<match_name>,<match_id>
```

The app will fetch the match, player and beatmap details from the API and populate the database. It's currently
hardcoded for a 1v1 match structure. Tournament maps are identified as any map in the match that satisfies the following
conditions:
- Is played on Score v2
- Is played as Team Versus
- Has exactly 3 players in the lobby (2 participants in first two slots + 1 referee)

Any map played in the lobby that doesn't satisfy these conditions are skipped, so just make sure you organise your
match lobbies around this fact when playing warmup maps etc. that shouldn't be accounted for in tournament statistics.

Due to matches just being regular multiplayer games in osu!, this app relies on the lobby name being in the [tournament format](https://osu.ppy.sh/help/wiki/osu!tourney/Multiplayer_Usage/) to
identify the players. In case of any typos in the name, the [typo list](./config/player_name_typo_list.yml) can be updated to map to the correct usernames.
