##
# TARGET: spot-base
# !! This is a builder image. Not for general use !!
# Use this as the base image for the Rails / Sidekiq services.
##
FROM ruby:2.7.7-alpine as spot-base
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add \
        aws-cli \
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
    HYRAX_UPLOAD_PATH=/spot/tmp/uploads \
    BUNDLE_FORCE_RUBY_PLATFORM=1

# @todo upgrade the Gemfile bundler version to 2 to remove version constraint
RUN gem install bundler

COPY ["Gemfile", "Gemfile.lock", "/spot/"]
RUN bundle config unset with && \
    bundle config unset without && \
    bundle config set without "development:test" && \
    bundle install --jobs "$(nproc)"

ENTRYPOINT ["/spot/bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "ssl://0.0.0.0:443?key=/spot/tmp/ssl/application.key&cert=/spot/tmp/ssl/application.crt"]

ARG build_date=""
ENV SPOT_BUILD_DATE="$build_date"

HEALTHCHECK CMD curl -skf https://localhost/healthcheck/default || exit 1


##
#  Target: spot-asset-builder
#  !! This is a builder image, do not use !!
##
FROM spot-base as spot-asset-builder
ENV RAILS_ENV=production
COPY . /spot

# Need to put in a fake FEDORA_URL variable so Wings can initialize
RUN SECRET_KEY_BASE="$(bin/rake secret)" \
    FEDORA_URL="http://fakehost:8080/rest" \
    bundle exec rake assets:precompile


##
# TARGET: spot-web
# Used for the user-facing application. Sets up UV files and installs nodejs/yarn dependencies.
##
FROM spot-base as spot-web-base
COPY config/uv config/uv

##
# TARGET: spot-web-development
# Used for the development version of the user-facing application.
# Installs Ruby development dependencies
##
FROM spot-web-base as spot-web-development
RUN bundle config unset with &&\
    bundle config unset without && \
    bundle config set with "development:test" && \
    bundle install --jobs "$(nproc)"
COPY . /spot/

ENV RAILS_ENV=development
ENV RAILS_CONSIDER_ALL_REQUESTS_LOCAL="1"
ENV RAILS_ENABLE_CONTROLLER_CACHING="0"

ENTRYPOINT ["/spot/bin/spot-dev-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "ssl://0.0.0.0:443?key=/spot/tmp/ssl/application.key&cert=/spot/tmp/ssl/application.crt"]


##
# TARGET: spot-web-production
# Precompiles assets for production
##
FROM spot-base as spot-web-production
ENV RAILS_ENV=production
COPY . /spot
COPY --from=spot-asset-builder /spot/public/assets /spot/public/assets
COPY --from=spot-asset-builder /spot/public/uv /spot/public/uv

##
# TARGET: fits-builder
# Downloads the .zip file found at $FITS_URL and extracts the files into `/output` for copying
# in the Sidekiq container. If the URL provided is a .zip of a Git branch (rather than a release),
# the files are extracted, built, and moved to the `/output` directory.
#
# By default this uses the release version defined by FITS_VERSION.
##
FROM maven:3.9-sapmachine-11 as fits-builder

# need bash shell to use compgen function below
SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash

RUN apt-get update && apt-get install -y unzip

# Version of FITS to install (stored in ENV as a troubleshooting measure)
# see: https://github.com/harvard-lts/fits
ARG FITS_VERSION="1.6.0"
ENV FITS_VERSION="${FITS_VERSION}"
ARG FITS_URL="https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip"
ENV FITS_URL="${FITS_URL}"

# Downloads the .zip file found at $FITS_URL and extracts the files into `/output` for copying
# in the Sidekiq container. If the URL provided is a .zip of a Git branch (rather than a release),
# the files are extracted, built, and moved to the `/output` directory.
RUN shopt -s dotglob; \
    mkdir /build /output; \
    curl -Ls -o /build/fits.zip "${FITS_URL}"; \
    unzip -d /build -qq /build/fits.zip; \
    if find /build -maxdepth 1 -type d -name "fits-*" | grep . > /dev/null; \
    then \
        mv /build/* /build; \
        cd /build && mvn clean package -DskipTests; \
        unzip -d /output -qq $(compgen -G "/build/target/fits-*.zip" | head -n 1); \
    else \
        mv /build/* /output; \
    fi; \
    chmod a+x /output/fits.sh

##
# TARGET: spot-worker
# Installs dependencies for running background jobs
##
FROM spot-base as spot-worker-base
# @see https://github.com/mperham/sidekiq/wiki/Memory#bloat
ENV MALLOC_ARENA_MAX=2
# We don't need the entrypoint script to generate an SSL cert
ENV SKIP_SSL_CERT=true

RUN apk --no-cache update && \
    apk --no-cache add \
        bash \
        ffmpeg \
        ghostscript \
        imagemagick \
        libreoffice \
        mediainfo \
        openjdk11-jre \
        perl \
        python3

RUN ln -s /usr/bin/python3 /usr/bin/python

COPY --from=fits-builder /output /usr/local/fits
ENV PATH="${PATH}:/usr/local/fits"

CMD ["bundle", "exec", "sidekiq"]
EXPOSE 3000

FROM spot-worker-base as spot-worker-development
ENV RAILS_ENV=development

RUN bundle config unset with &&\
    bundle config unset without && \
    bundle config set with "development:test" && \
    bundle install --jobs "$(nproc)"
COPY . /spot/

##
# Target: spot-worker-production
# Copies compiled assets for use in production.
##
FROM spot-worker-base as spot-worker-production
ENV RAILS_ENV=production

COPY . /spot/
COPY --from=spot-asset-builder /spot/public/assets /spot/public/assets
COPY --from=spot-asset-builder /spot/public/uv /spot/public/uv
