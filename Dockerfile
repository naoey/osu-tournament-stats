FROM ruby:3.3.0-bookworm

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/*

RUN gem install bundler

WORKDIR /app

COPY ./Gemfile ./
COPY ./Gemfile.lock ./

RUN bundle install
RUN yarn install

RUN groupadd ots && useradd -g ots ots

ENTRYPOINT ["/app/docker/development/boot.sh"]
CMD ["serve"]
