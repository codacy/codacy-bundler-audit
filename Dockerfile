FROM ruby:3.2.0-alpine3.17

LABEL maintainer="team@codacy.com"

# git is needed for bundler-audit update
RUN adduser -u 2004 -D docker && \
    apk add --no-cache git

WORKDIR /opt/docker
USER docker

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle config set no-cache 'true' && \
    bundle install --without=test && \
    bundler-audit update

COPY lib lib
COPY bin bin
COPY docs /docs

WORKDIR /src

ENTRYPOINT ["/opt/docker/bin/run"]
