# base image
FROM ruby:2.4.3 as spot-base

# add node + yarn repositories (do we need both?)
RUN apt-get update && apt-get install -y -qq apt-transport-https apt-utils \
    && (curl -sL https://deb.nodesource.com/setup_10.x | bash) \
    && (curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -) \
    && (curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -) \
    && (echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list)

# add ghostscript, ImageMagick, and libreoffice to the jobs service only
RUN apt-get update && apt-get install -y \
    yarn \
    nodejs \
    netcat \
    ghostscript \
    ImageMagick \
    libreoffice

RUN gem update bundler

WORKDIR /spot

# get installation files copied over first, run installations, _then_ copy
# the application files over, so that we can rely on docker's cache first
# when rebuilding.
#
# a) bundle + yarn files
COPY ["Gemfile", "Gemfile.lock", "package.json", "yarn.lock", "/spot/"]

# b) uv configuration files (yarn will copy files to public as part of the installation process)
RUN mkdir config
COPY config/uv config/uv

# install dependencies
RUN bundle install --jobs "$(nproc)" && yarn install

# finally, copy our current work files to the image
COPY . /spot

VOLUME ["/spot/public", "/spot/tmp"]

ENTRYPOINT ["bin/spot-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]
