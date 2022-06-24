# Base Image
# ----------
# Used as the root for both the application (user-facing) side and worker images.
# These are the bare essential dependencies for running the application.
ARG RUBY_VERSION=2.4.6-alpine3.10
FROM ruby:$RUBY_VERSION as spot-base

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add \
        build-base \
        coreutils \
        curl \
        git \
        netcat-openbsd \
        nodejs \
        openssl \
        postgresql \
        postgresql-dev \
        ruby-dev \
        tzdata \
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

##
#  Target: spot-asset-builder
#  !! This is a builder image, do not use !!
##
FROM spot-base as spot-asset-builder
ENV RAILS_ENV=production

RUN apk add yarn
COPY . /spot

RUN SECRET_KEY_BASE="$(bin/rake secret)" \
    bundle exec rake assets:precompile


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
        bash \
        ffmpeg \
        ghostscript \
        imagemagick \
        libreoffice \
        mediainfo \
        openjdk11-jre \
        perl

# ENV FITS_VERSION=1.5.1
# RUN https://github.com/harvard-lts/fits/releases/download/$FITS_VERSION/fits-$FITS_VERSION.zip

# TODO:
# - install local FITS cli + set ENV for FITS_PATH
# - install open office + set ENV

# RUN bundle config unset --local without && \
    # bundle install --jobs "$(nproc)"

ENV PATH="${PATH}:/usr/local/fits"

COPY . /spot
CMD ["bundle", "exec", "sidekiq"]
EXPOSE 3000


##
# Target: spot-worker-production
# Copies compiled assets for use in production.
##
FROM spot-worker as spot-worker-production
ENV RAILS_ENV=production
COPY --from=spot-asset-builder /spot/public /spot/public
