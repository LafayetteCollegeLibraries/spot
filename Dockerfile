##
# TARGET: spot-base
# !! This is a builder image. Not for general use !!
# Use this as the base image for the Rails / Sidekiq services.
##
FROM ruby:2.7.8-slim-bullseye as spot-base

RUN apt update && \
    apt install -y --no-install-recommends ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt update && apt install -y --no-install-recommends \
        awscli \
        build-essential \
        coreutils \
        git \
        netcat-openbsd \
        nodejs \
        openssl \
        postgresql-13 libpq-dev \
        ruby-dev \
        tzdata \
        zip

WORKDIR /spot

ENV HYRAX_CACHE_PATH=/spot/tmp/cache \
    HYRAX_DERIVATIVES_PATH=/spot/tmp/derivatives \
    HYRAX_UPLOAD_PATH=/spot/tmp/uploads \
    BUNDLE_FORCE_RUBY_PLATFORM=1

RUN corepack enable

COPY ["Gemfile", "Gemfile.lock", "/spot/"]
RUN gem install bundler:$(tail -n 1 Gemfile.lock | sed -e 's/\s*//')
RUN bundle config unset with && \
    bundle config unset without && \
    bundle config set without "development:test" && \
    bundle install --jobs "$(nproc)"

ARG build_date=""
ENV SPOT_BUILD_DATE="$build_date"

ENTRYPOINT ["/spot/bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "ssl://0.0.0.0:443?key=/spot/tmp/ssl/application.key&cert=/spot/tmp/ssl/application.crt"]

HEALTHCHECK CMD curl -skf https://localhost/healthcheck/default || exit 1

##
#  Target: spot-asset-builder
#  !! This is a builder image, do not use !!
##
FROM spot-base as spot-asset-builder
ENV RAILS_ENV=production
COPY . /spot

RUN SECRET_KEY_BASE="$(bin/rake secret)" FEDORA_URL="http://fakehost:8080/rest" bundle exec rake assets:precompile

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
COPY --from=spot-asset-builder /spot/public/assets/* /spot/public/assets/
COPY --from=spot-asset-builder /spot/public/uv/* /spot/public/uv/


##
# TARGET: spot-worker
# Installs dependencies for running background jobs
##
FROM spot-base as spot-worker-base
# @see https://github.com/mperham/sidekiq/wiki/Memory#bloat
ENV MALLOC_ARENA_MAX=2
# We don't need the entrypoint script to generate an SSL cert
ENV SKIP_SSL_CERT=true

RUN apt update && apt install -y --no-install-recommends \
        bash \
        ffmpeg \
        ghostscript \
        imagemagick \
        libreoffice \
        mediainfo \
        openjdk-11-jre \
        perl \
        python3 \
        unzip

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN bundle install --jobs "$(nproc)" --with="development test"

# (from https://github.com/samvera/hyrax/blob/3.x-stable/Dockerfile#L59-L65)
RUN mkdir -p /usr/local/fits && \
    cd /usr/local/fits && \
    wget "https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip" -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /usr/local/fits/fits.sh

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
