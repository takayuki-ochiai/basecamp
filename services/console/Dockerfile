FROM ruby:2.6.5-slim as base
ENV LANG C.UTF-8
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

EXPOSE  3000
WORKDIR $WORKSPACE
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

RUN set -x && \
    : "create directory" && \
    mkdir -p $WORKSPACE $BUNDLE_APP_CONFIG && \
    chown -R rails:rails $WORKSPACE && \
    chown -R rails:rails $BUNDLE_APP_CONFIG

USER rails
RUN set -x && \
    : "install rails dependent packages" && \
    bundle update && \
    bundle install

# Develop Image
FROM base as dev
ENV RAILS_ENV development
CMD ["rails", "server", "-b", "0.0.0.0"]

# Source Image
FROM base as source
COPY --chown=rails:rails . .
ADD . $WORKSPACE

# Production Image
FROM source as prod
ENV RAILS_ENV production
# TODO: 暗号化やらassets precompileやら
