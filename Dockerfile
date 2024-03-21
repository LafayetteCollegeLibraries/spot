##
# Target: pdfjs-installer
# !! This is a builder image, do not use directly !!
##
FROM alpine:3 as pdfjs-installer
ARG PDFJS_VERSION="4.0.379"
ENV PDFJS_VERSION="${PDFJS_VERSION}"
ADD https://github.com/mozilla/pdf.js/releases/download/v${PDFJS_VERSION}/pdfjs-${PDFJS_VERSION}-legacy-dist.zip /tmp/pdfjs.zip
RUN unzip -d /tmp/pdfjs /tmp/pdfjs.zip
COPY config/pdfjs/viewer.html /tmp/pdfjs/web/viewer.html


##
# Target: fits-installer
# !! This is a builder image, do not use directly !!
#
# @see https://github.com/harvard-lts/fits
# @see https://github.com/samvera/hyrax/blob/3.x-stable/Dockerfile#L59-L65
##
FROM alpine:3 as fits-installer
ARG FITS_VERSION="1.6.0"
ENV FITS_VERSION="${FITS_VERSION}"
ADD https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip /tmp/fits.zip

RUN unzip -d /tmp/fits /tmp/fits.zip && \
    chmod a+x /tmp/fits/fits.sh


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
        libpq-dev \
        libxml2 \
        libxml2-dev \
        libxslt-dev \
        netcat-openbsd \
        nodejs \
        openssl \
        postgresql-13 \
        ruby-dev \
        tzdata \
        zip

WORKDIR /spot

ENV HYRAX_CACHE_PATH=/spot/tmp/cache \
    HYRAX_DERIVATIVES_PATH=/spot/tmp/derivatives \
    HYRAX_UPLOAD_PATH=/spot/tmp/uploads \
    BUNDLE_FORCE_RUBY_PLATFORM=1

RUN corepack enable

COPY Gemfile.lock /spot/
RUN gem install bundler:$(tail -n 1 Gemfile.lock | sed -e 's/\s*//')

COPY Gemfile /spot/
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
# TARGET: spot-web-development
# Used for the development version of the user-facing application.
# Installs Ruby development dependencies
##
FROM spot-base as spot-web-development
RUN bundle config unset with &&\
    bundle config unset without && \
    bundle config set with "development:test" && \
    bundle install --jobs "$(nproc)"
COPY . /spot/
COPY --from=pdfjs-installer /tmp/pdfjs /spot/public/pdf

ENV RAILS_ENV=development

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
COPY --from=pdfjs-installer /tmp/pdfjs /spot/public/pdf


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

# fix for ImageMagick to remove security policy for PDFs (and other ghostscript types)
# @see https://stackoverflow.com/questions/52998331/imagemagick-security-policy-pdf-blocking-conversion#comment110879511_59193253
RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml

COPY --from=fits-installer /tmp/fits /usr/local/fits
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
