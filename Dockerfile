FROM ruby:2.6.5-buster

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN groupadd ots && useradd -g ots ots

ENTRYPOINT ["/opt/app/docker/development/boot.sh"]