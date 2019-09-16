# base image
FROM ruby:2.4.2

# install deps for our Rails app
RUN apt-get update && apt-get install -y \
  ghostscript \
  ImageMagick \
  libreoffice \
  nodejs

# get situated
RUN mkdir /app
WORKDIR /app

# install dependencies
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# copy the codebase to the workdir
COPY . .

# let's get it started
EXPOSE 3000
CMD ['bundle', 'exec', 'rails', 'server', '-b', '0.0.0.0']
