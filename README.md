# Redmined

A docked CLI for Redmine development environment. Inspired by [rails/docked](https://github.com/rails/docked).

## Prerequisites

* Source code of [Redmine](https://github.com/redmine/redmine) or its distribution such as [RedMica](https://github.com/redmica/redmica)
* Docker

## Installation

Create a Docker volume for the bundle cache.
```shell
docker volume create redmine-bundle-cache
```

Define the `redmined` command with the following code.
```bash
function redmined() {
  local container_name="redmined-container"

  if [ ! $(docker ps -q --filter name=$container_name) ]; then
    docker run --name $container_name --rm -it \
      -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) \
      -v ${PWD}:/redmine -v redmine-bundle-cache:/bundle \
      -p 3000:3000 ghcr.io/hidakatsuya/redmined $@
  else
    docker exec -it $container_name $@
  fi
}
```

## Usage

```shell
cd your-redmine-root-directory
```

Create configuration for SQLite database.

```shell
cat <<EOS > config/database.yml
development:
  adapter: sqlite3
  database: db/development.sqlite3
test:
  adapter: sqlite3
  database: db/test.sqlite3
EOS
```

Setup and start Redmine.

```shell
redmined bundle install
redmined bin/rails db:prepare
redmined bin/rails s
```

Run tests.

```
redmined bin/rails test
redmined bin/rails test:system
```

> [!NOTE]
> Since Chrome is not installed on the ARM64 platform, `test:system` task can't be executed.

## Tips

### Executing redmined command with modified environment variables

```shell
redmined env RAILS_ENV=development bin/about
```
