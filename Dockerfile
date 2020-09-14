# base image
FROM ruby:2.4.3

ARG EXTRA_APT_PACKAGES="git"

# add node + yarn repositories (do we need both?)
RUN apt-get update && apt-get install -y -qq apt-transport-https apt-utils \
    && (curl -sL https://deb.nodesource.com/setup_12.x | bash) \
    && (curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -) \
    && (echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list)

# add ghostscript, ImageMagick, and libreoffice to the jobs service only
RUN apt-get update && apt-get install -y yarn nodejs $EXTRA_APT_PACKAGES

RUN gem update bundler
RUN mkdir -p /spot
WORKDIR /app

# copy our current work files to the image
COPY . /app
RUN bundle install --jobs "$(nproc)"

ENTRYPOINT ["bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]
