FROM ruby:3.3.0-bookworm AS builder

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -

RUN gem install bundler

WORKDIR /app

COPY ./Gemfile ./
COPY ./Gemfile.lock ./
COPY ./package.json ./
COPY /pnpm-lock.yaml ./

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

RUN bundle install
RUN pnpm install

FROM builder

RUN groupadd ots && useradd -g ots ots

ENTRYPOINT ["/app/docker/development/boot.sh"]
