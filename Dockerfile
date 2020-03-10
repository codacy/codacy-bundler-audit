FROM ruby:2.7.0-alpine3.11

LABEL maintainer="team@codacy.com"

# git is needed for bundler-audit update
RUN apk add git

RUN adduser -u 2004 -D docker
USER docker

WORKDIR /opt/docker

COPY Gemfile* /opt/docker/
RUN bundle install --without=test --no-cache && \
    rm -rf ~/.bundle
RUN bundler-audit update
COPY lib /opt/docker/lib/
COPY bin /opt/docker/bin/
COPY docs /docs

WORKDIR /src

ENTRYPOINT ["/opt/docker/bin/run"]
