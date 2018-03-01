FROM ruby:2.4.0

MAINTAINER dxw <rails@dxw.com>

RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev --fix-missing --no-install-recommends

ENV PHANTOM_JS="phantomjs-2.1.1-linux-x86_64"
RUN curl -OLk https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2
RUN tar xvjf $PHANTOM_JS.tar.bz2
RUN mv $PHANTOM_JS/bin/phantomjs /usr/local/bin/phantomjs
RUN rm -rf $PHANTOM_JS

ENV INSTALL_PATH /srv/dfe-tvs
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# set rails environment
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV RACK_ENV=${RAILS_ENV:-production}

COPY Gemfile $INSTALL_PATH/Gemfile
COPY Gemfile.lock $INSTALL_PATH/Gemfile.lock

RUN gem install bundler

ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}

RUN bundle install --without development test

COPY . $INSTALL_PATH

RUN bundle exec rake --quiet assets:precompile

# bundle ruby gems based on the current environment, default to production
RUN \
  if [ "$RAILS_ENV" = "production" ]; then \
    bundle install --without development test --retry 10; \
  else \
    bundle install --retry 10; \
  fi

EXPOSE 3000
CMD ["bundle", "exec", "rails s"]
