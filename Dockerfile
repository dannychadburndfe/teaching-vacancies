ARG PROD_PACKAGES="libxml2=2.9.12-r2 libxslt=1.1.34-r1 libpq=14.1-r5 tzdata=2021e-r0 shared-mime-info=2.1-r0 gmp=6.2.1-r1"

FROM ruby:3.1.0-alpine3.15 AS builder

WORKDIR /app

ARG PROD_PACKAGES
ENV DEV_PACKAGES="gcc=10.3.1_git20211027-r0 libc-dev=0.7.2-r3 make=4.3-r0 yarn=1.22.17-r0 postgresql13-dev=13.5-r1 gmp=6.2.1-r1 build-base=0.5-r2 git"
RUN apk add --no-cache $PROD_PACKAGES $DEV_PACKAGES
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:2.3.5 --no-document


COPY Gemfile* ./
RUN bundle config set --local without 'development test'
RUN bundle install --no-binstubs --retry=5 --jobs=4 --no-cache

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE=required-to-run-but-not-used RAILS_SERVE_STATIC_FILES=1 bundle exec rake webpacker:compile

RUN rm -rf node_modules log tmp yarn.lock && \
      rm -rf /usr/local/bundle/cache && \
      rm -rf .env && touch .env && \
      find /usr/local/bundle/gems -name "*.c" -delete && \
      find /usr/local/bundle/gems -name "*.h" -delete && \
      find /usr/local/bundle/gems -name "*.o" -delete && \
      find /usr/local/bundle/gems -name "*.html" -delete


# this stage reduces the image size.
FROM ruby:3.1.0-alpine3.15 AS production

WORKDIR /app

ARG PROD_PACKAGES
RUN apk -U upgrade && apk add --no-cache $PROD_PACKAGES
RUN echo "Europe/London" > /etc/timezone && \
        cp /usr/share/zoneinfo/Europe/London /etc/localtime
RUN gem install bundler:2.3.5 --no-document

COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
RUN echo export PATH=/usr/local/bundle/:/usr/local/bin/:$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

ARG COMMIT_SHA
ENV COMMIT_SHA=$COMMIT_SHA

EXPOSE 3000
CMD bundle exec rails db:migrate && bundle exec rails s
