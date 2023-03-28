FROM hexpm/elixir:1.14.2-erlang-24.3.4.10-debian-bullseye-20230227 AS builder

WORKDIR /app
COPY . .

ENV MIX_ENV=prod

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix compile  && \
    mix release

ENTRYPOINT ./_build/prod/rel/protohackers/bin/protohackers start


