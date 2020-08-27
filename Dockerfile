# base image
FROM ruby:2.4.3

# add yarn repository
RUN apt-get update && apt-get install -y -qq apt-transport-https apt-utils \
    && (curl -sL https://deb.nodesource.com/setup_12.x | bash) \
    && (curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -) \
    && (echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list) \
    && apt-get update && apt-get install -y \
       ghostscript \
       ImageMagick \
       libreoffice \
       yarn \
       nodejs

COPY . /spot
WORKDIR /spot
RUN bundle install && yarn install
RUN mkdir -p /spot/tmp/derivatives /spot/tmp/ingest

# let's get it started
EXPOSE 3000
VOLUME /spot

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
