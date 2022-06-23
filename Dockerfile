# Base Image
# ----------
# Used as the root for both the application (user-facing) side and worker images.
# These are the bare essential dependencies for running the application.
ARG RUBY_VERSION=2.4.6-alpine3.10
FROM ruby:$RUBY_VERSION as spot-base

# system dependencies
# TODO: imagemagick might belong in the worker container instead?
RUN apk --no-cache upgrade && \
    apk --no-cache add \
        build-base \
        coreutils \
        curl \
        git \
        netcat-openbsd \
        nodejs \
        openssl \
        postgresql postgresql-dev \
        ruby-dev \
        tzdata \
        yarn \
        zip

WORKDIR /spot

ENV HYRAX_CACHE_PATH=/spot/tmp/cache \
    HYRAX_DERIVATIVES_PATH=/spot/tmp/derivatives \
    HYRAX_UPLOAD_PATH=/spot/tmp/uploads

# match our Gemfile.lock version
# TODO: upgrade the Gemfile bundler version to 2
RUN gem install bundler:1.13.7

# install dependencies
# ---
# get installation files copied over first, run installations, _then_ copy
# the application files over, so that we can rely on docker's cache first
# when rebuilding.
#
# a) bundle + yarn files
COPY ["Gemfile", "Gemfile.lock", "package.json", "yarn.lock", "/spot"]

# b) make directories for installation configuration (`config/` and `public/`)
RUN mkdir -p /spot/config /spot/public

# c) install production dependencies
RUN bundle config set --local without "development test" && \
    bundle install --jobs "$(nproc)"

# d) copy the application files
COPY . /spot

ENTRYPOINT ["/spot/bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-u", "puma", "-b", "ssl://0.0.0.0:443?key=/spot/tmp/ssl/application.key&cert=/spot/tmp/ssl/application.crt"]


##
# TARGET: spot-web
# Used for the user-facing application. Sets up UV files and installs nodejs/yarn dependencies.
##
FROM spot-base as spot-web-base
COPY config/uv config/uv

# run yarn install first so we don't need to always rerun when updating gems
RUN yarn install


##
# TARGET: spot-web-development
# Used for the development version of the user-facing application.
# Installs Ruby development dependencies
##
FROM spot-web-base as spot-web-development
RUN bundle config unset --local without && \
    bundle config set --local with "development test" && \
    bundle install --jobs "$(nproc)"


##
# TARGET: spot-web-production
# Precompiles assets for production
##
FROM spot-web-base as spot-web-production
RUN RAILS_ENV=production DATABASE_URL="postgres://fake" SECRET_KEY_BASE="secret-shh" bundle exec rake assets:precompile


##
# TARGET: spot-worker
# Installs dependencies for running background jobs
##
FROM spot-base as spot-worker
RUN apk --no-cache upgrade && \
    apk --no-cache add \
        imagemagick \
        ghostscript

# TODO:
# - install local FITS cli + set ENV for FITS_PATH
# - install open office + set ENV

RUN bundle config unset --local without && \
    bundle install --jobs "$(nproc)"

CMD ["bundle", "exec", "sidekiq"]
