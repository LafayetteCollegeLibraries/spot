# base image
ARG RUBY_VERSION=2.4.3-alpine3.7
FROM ruby:$RUBY_VERSION as spot-base

# system dependencies
# TODO: imagemagick might belong in the worker container instead?
RUN apk --no-cache upgrade && \
    apk --no-cache add \
        build-base \
        curl \
        imagemagick \
        tzdata \
        netcat-openbsd \
        nodejs yarn \
        zip \
        postgresql-dev \
        git

# let's not run this as root
# (taken from hyrax's Dockerfile)
RUN addgroup -S -g 101 app && \
    adduser -S -G app -u 1001 -s /bin/sh -h /app app
RUN mkdir /spot && chown -R 1001:101 /spot
USER app

WORKDIR /spot
RUN gem update bundler

# install dependencies
# ---
# get installation files copied over first, run installations, _then_ copy
# the application files over, so that we can rely on docker's cache first
# when rebuilding.
#
# a) bundle + yarn files
COPY --chown=1001:101 ["Gemfile", "Gemfile.lock", "package.json", "yarn.lock", "/spot"]

# b) uv configuration files (yarn will copy files to public as part of the installation process)
RUN mkdir -p /spot/config
COPY config/uv config/uv

# c) install dependencies
ARG BUNDLE_WITHOUT="development test"
RUN mkdir -p /spot/vendor
RUN bundle install --jobs "$(nproc)" --path "/spot/vendor"

# d) copy the application files
COPY --chown=1001:101 . /spot

ENTRYPOINT ["/spot/bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "-v", "-b", "tcp://0.0.0.0:3000"]

FROM spot-base as spot-app
RUN yarn install

# precompile assets
# RUN DATABASE_URL="postgres://fake" SECRET_KEY_BASE="secret-shh" bundle exec rake assets:precompile

FROM spot-base as spot-worker
USER root
RUN apk --no-cache upgrade && \
    apk --no-cache add \
        imagemagick \
        ghostscript

USER app
ARG BUNDLE_WITHOUT=""
RUN bundle install --jobs "$(nproc)" --path "/spot/vendor"
CMD ["bundle", "exec", "sidekiq"]
