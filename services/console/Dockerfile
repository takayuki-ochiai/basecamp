FROM ruby:2.6.5-slim as base
ENV WORKSPACE /app

RUN set -x && \
    : "for install yarn" && \
    apt-get update -qq && \
    apt-get install -y curl wget gnupg && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    : "for bundle install and webpacker" && \
    apt-get update -qq && \
    apt-get install -y \
        # for bundle install
        build-essential default-libmysqlclient-dev \
        # for webpacker
        nodejs yarn git \
        vim less && \
    apt-get clean

RUN set -x && \
    : "install bundler" && \
    gem install bundler

RUN set -x && \
    : "create user and group" && \
    groupadd -r --gid 1000 rails && \
    useradd -m -r --uid 1000 --gid 1000 rails

RUN curl -sL -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 && \
    chmod +x /usr/local/bin/dumb-init

EXPOSE  3000
WORKDIR $WORKSPACE
COPY --chown=rails:rails Gemfile Gemfile.lock package.json yarn.lock ./
RUN set -x && \
    : "create directory" && \
    mkdir -p $WORKSPACE $BUNDLE_APP_CONFIG && \
    chown -R rails:rails $WORKSPACE && \
    chown -R rails:rails $BUNDLE_APP_CONFIG

USER rails
RUN set -x && \
    : "install rails dependent packages" && \
    bundle update && \
    bundle install && \
    yarn install

# debug用にsleep infinityで起動するようにする
CMD ["sleep", "infinity"]

FROM base as source
COPY --chown=rails:rails . .

# Develop Image
FROM source as dev
ENV RAILS_ENV development
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# Production Image
FROM source as prod
ENV RAILS_ENV production
# TODO: 暗号化やらassets precompileやら
