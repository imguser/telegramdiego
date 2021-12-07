FROM ruby:2.5.1-alpine
# set an environment variable to specify the Bundler version
ENV BUNDLER_VERSION=2.0.2
# add the packages that you need to work with the application to the Dockerfile
RUN apk add --update --no-cache \
      binutils-gold \
      build-base \
      curl \
      file \
      g++ \
      gcc \
      git \
      less \
      libstdc++ \
      libffi-dev \
      libc-dev \ 
      linux-headers \
      libxml2-dev \
      libxslt-dev \
      libgcrypt-dev \
      make \
      netcat-openbsd \
      nodejs \
      openssl \
      pkgconfig \
      postgresql-dev \
      python \
      python3 \
      tzdata \
      yarn 
# install the appropriate bundler version
RUN gem install bundler -v 2.0.2
# set the working directory for the application on the container
WORKDIR /app
# Copy over your Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./
# set the configuration options for the nokogiri gem build
RUN bundle config build.nokogiri --use-system-libraries
# install the project gems
RUN bundle check || bundle install

# copy package.json and yarn.lock from your current project directory on 
# the host to the container
COPY package.json ./
# install the required packages with yarn install
RUN yarn install --check-files

# install python depencdecies
COPY requirements.txt ./
RUN python3 -m pip install -r requirements.txt

# copy over the rest of the application code and start the 
# application with an entrypoint script:
COPY . ./

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]