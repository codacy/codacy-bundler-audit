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

# Empty (release builds): ship the latest ruby-advisory-db.
# Set (CI test image): pin the DB to that commit so docs/ expected results stay stable.
ARG ADVISORY_DB_REF=""
RUN if [ -n "$ADVISORY_DB_REF" ]; then \
      cd "$HOME/.local/share/ruby-advisory-db" && \
      git fetch --quiet origin "$ADVISORY_DB_REF" && \
      git checkout --quiet "$ADVISORY_DB_REF"; \
    fi

COPY lib lib
COPY bin bin
COPY docs /docs

WORKDIR /src

ENTRYPOINT ["/opt/docker/bin/run"]