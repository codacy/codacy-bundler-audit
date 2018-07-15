FROM ruby:2.5.1-alpine3.7

RUN adduser -u 2004 -D docker
USER docker

WORKDIR /opt/docker

COPY Gemfile* /opt/docker/
RUN bundle install --without=test --no-cache && \
    rm -rf ~/.bundle

COPY lib /opt/docker/lib/
COPY bin /opt/docker/bin/
COPY docs /docs

WORKDIR /src

ENTRYPOINT ["/opt/docker/bin/run"]
