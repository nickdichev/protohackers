FROM elixir:1.14.0-alpine AS builder

WORKDIR /app
COPY . .

ENV MIX_ENV=prod

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix compile  && \
    mix release

ENTRYPOINT ./_build/prod/rel/protohackers/bin/protohackers start


