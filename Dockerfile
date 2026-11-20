FROM ruby:4.0.10-alpine3.24

LABEL maintainer="team@codacy.com"

# git is needed for bundler-audit update
RUN adduser -u 2004 -D docker && \
    apk add --no-cache git && \
    mkdir -p /opt/docker && \
    chown docker:docker /opt/docker

WORKDIR /opt/docker
USER docker

COPY --chown=docker:docker Gemfile Gemfile.lock ./
RUN bundle config set no-cache 'true' && \
    bundle config set without 'test' && \
    bundle install && \
    bundler-audit update

COPY lib lib
COPY bin bin
COPY docs /docs

WORKDIR /src

ENTRYPOINT ["/opt/docker/bin/run"]