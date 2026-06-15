# Single-stage dev/CI image. The real Enni Dockerfile is a multi-stage,
# Node-aware production build; this skeleton uses importmap (no Node build step)
# so one stage is enough and `docker compose up` stays a single command.
FROM ruby:3.4

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends build-essential libpq-dev postgresql-client \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gems install into the image at /usr/local/bundle (outside /app) so the compose
# bind-mount of the source over /app does not hide them.
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
