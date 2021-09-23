FROM ruby:3.0.2-alpine3.14

LABEL maintainer="team@codacy.com"

RUN adduser -u 2004 --disabled-password docker

# git is needed for bundler-audit update
RUN apk add --no-cache git

WORKDIR /opt/docker
USER docker

COPY Gemfile /opt/docker/
COPY Gemfile.lock /opt/docker/

RUN bundle config set no-cache 'true' && \
    bundle install --without=test && \
    bundler-audit update

COPY lib lib
COPY bin bin
COPY docs /docs

WORKDIR /src

ENTRYPOINT ["/opt/docker/bin/run"]
