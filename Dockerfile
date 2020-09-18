# base image
FROM ruby:2.4.3 as spot-base

ARG EXTRA_APT_PACKAGES="git"

# add node + yarn repositories (do we need both?)
RUN apt-get update && apt-get install -y -qq apt-transport-https apt-utils \
    && (curl -sL https://deb.nodesource.com/setup_12.x | bash) \
    && (curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -) \
    && (echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list)

# add ghostscript, ImageMagick, and libreoffice to the jobs service only
RUN apt-get update && apt-get install -y \
    git \
    yarn \
    nodejs \
    netcat \
    ghostscript \
    ImageMagick \
    libreoffice

RUN gem update bundler

WORKDIR /spot
COPY Gemfile      /spot/Gemfile
COPY Gemfile.lock /spot/Gemfile.lock

RUN bundle install --jobs "$(nproc)"

# copy our current work files to the image _after_ installing our dependencies
COPY . /spot

ENTRYPOINT ["bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]

# -----

FROM spot-base as spot

RUN yarn install

# -----

FROM spot-base as spot-sidekiq

RUN apt-get update && apt-get install -y \
    ghostscript \
    ImageMagick \
    libreoffice

CMD ["bundle", "exec", "sidekiq"]
