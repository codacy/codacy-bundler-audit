FROM ruby:3.0.2-alpine3.13

LABEL maintainer="team@codacy.com"

# git is needed for bundler-audit update
RUN apk add --no-cache git

WORKDIR /work

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle config set no-cache 'true' && \
    bundle install --without=test && \
    bundler-audit update

COPY lib lib
COPY bin bin
COPY docs /docs

WORKDIR /src

ENTRYPOINT ["/work/bin/run"]
