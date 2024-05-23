## **osu-tournament-stats**
![Build Status](https://github.com/naoey/osu-tournament-stats/actions/workflows/main.yml/badge.svg) ![Code Quality](https://github.com/naoey/osu-tournament-stats/actions/workflows/github-code-scanning/codeql/badge.svg)

----

Nowadays just the main repository for [osu!india](https://discord.gg/G8uYKhzujz)'s Discord bot (known as KelaBot). Initially started off as a tool to show statistics for various community osu! matches that were organised within the group, hence the repo name. I just couldn't be bothered to rename the repo and break connections.

Expect a lot of legacy crap and bad, hacky code as this isn't something I've spent a lot of time on carefully crafting.

Reach out to me on Discord if there's anything you want to know about running this locally or contributing.

### Running locally

Running the project locally should be pretty straightforward. Clone the repo and create a `.env` file based on [`.env.example`](./.env.example). Then, one of two options:
1. Using Docker (recommended): `docker-compose up`
2. Running Rails directly: `./bin/rails s`

For option 2, it's up to you to ensure the environment is ready for running Ruby + Node, including having all the Bundler and Yarn dependencies installed.

For option 1, any subsequent Rails commands will have to be run from inside the `ots_rails` container. This can be done by opening an interactive shell into the container using `docker-compose exec ots_rails "/bin/bash"`. After opening this session, it's recommended to set `export DISCORD_ENABLED=0` in the shell so that each Rails command won't start up another bot instance in case you have it enabled in your `.env`.

Once the Rails server is up and running using either option, run `./bin/rails db:migrate` to bring the database schema up. I may eventually create some seed data from the real database for local testing.

### Contributing

Any contributions are welcome, but keep in mind the primary goal of this project now is to support osu!india's Discord bot.

I also can't guarantee contributions will be accepted and definitely not on a timely basis.
