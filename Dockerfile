# base image
FROM ruby:2.4.3

VOLUME /spot

# add yarn repository
RUN apt-get update && apt-get install -y -qq apt-transport-https apt-utils \
    && (curl -sL https://deb.nodesource.com/setup_12.x | bash) \
    && (curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -) \
    && (echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list)

# install deps for our Rails app
RUN apt-get update && apt-get install -y \
  ghostscript \
  ImageMagick \
  libreoffice \
  yarn \
  nodejs

WORKDIR /spot
COPY Gemfile /spot/Gemfile
COPY Gemfile.lock /spot/Gemfile.lock
RUN bundle install && yarn install

# let's get it started
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
