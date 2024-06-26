# Redmined

A docked CLI for Redmine development environment. Inspired by [rails/docked](https://github.com/rails/docked).

## Features

* Requires only Docker CLI
* Supports running most Redmine tests
* CLI can be executed in subdirectories
* Supports multiple Redmine development environments

## Prerequisites

* Source code of [Redmine](https://github.com/redmine/redmine) or its distribution such as [RedMica](https://github.com/redmica/redmica)
* Docker

## Installation

Create a Docker volume for the bundle cache.

```shell
docker volume create redmine-bundle-cache
```

Download [redmined](./redmined) and place it in a location in your PATH, such as `~/.local/bin/`, and grant execution permission.

If `curl` is available, you can also install it with the following command.

```shell
curl https://raw.githubusercontent.com/hidakatsuya/redmined/main/redmined -o ~/.local/bin/redmined && chmod +x $_
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

```shell
redmined bin/rails test
redmined bin/rails test:system
```

> [!NOTE]
> Since Chrome is not installed on the ARM64 platform, `test:system` task can't be executed.

## Settings

* `REDMINED_CONTAINER_NAME` Container name for redmined. If not set, use "redmined-container" as default.
* `REDMINED_MAP_HOST_USER_TO_CONTAINER_USER` Map the UID and GID of the host user to the container user
* `REDMINED_BUNDLE_CACHE_VOLUME` Volume name for bundler cache. If not set, use "redmine-bundle-cache" as default.
* `REDMINED_IMAGE` Docker image for redmined. If not set, use "ghcr.io/hidakatsuya/redmined" as default.
* `REDMINED_PUBLISH_PORT` Port mapping for Redmine. If not set, use "3000:3000" as default.

See [redmined](https://github.com/hidakatsuya/redmined/blob/main/redmined) for further details.

## Tips

### Executing redmined command with modified environment variables

```shell
redmined env RAILS_ENV=development bin/about
```

### Developing a Redmine plugin with Redmined CLI

Since Redmined CLI supports running in subdirectories, you can run `redmined` in `plugins/redmine_xxxx/`.

This means you can develop a Redmine plugin in the following way.

Suppose your Redmine source code is stored as follow:
```
/home/you/redmine
  ├── app/
  ├── plugins/
  :
```

Then, place your Redmine plugin in `plugins/redmine_your_plugin` and go to that directory.

```shell
cd plugins/redmine_your_plugin
```

You can run commands such as `bin/rails s` or `bin/rails redmine:plugins:test` under the plugins directory. You don't need to navigate to the Redmine root directory to run those commands.

```shell
pwd
/path/to/redmine/plugins/redmine_your_plugin

redmined bin/rails redmine:plugins:test
redmined bin/rails s
```

### Using separate environments for multiple Redmines

This section introduces how to develop in multiple Redmine environments using the environment variables of Redmined and [direnv](https://github.com/direnv/direnv).

As an example, consider an environment where Redmine is developed with Ruby 3.3 and RedMica with Ruby 3.2.

First, prepare the source code for Redmine and RedMica.
```
/home/you/
  ├── redmica/
  └── redmine/
```

Move to the `redmine/` directory and execute the following commands.
```shell
docker volume create redmine-bundle-cache

cat <<EOF > .envrc
export REDMINED_IMAGE=ghcr.io/hidakatsuya/redmined:ruby3.3
export REDMINED_BUNDLE_CACHE_VOLUME=redmine-bundle-cache
EOF

direnv allow .
```

Next, move to the `redmica/` directory and execute the following commands.
```shell
docker volume create redmica-bundle-cache

cat <<EOF > .envrc
export REDMINED_IMAGE=ghcr.io/hidakatsuya/redmined:ruby3.2
export REDMINED_BUNDLE_CACHE_VOLUME=redmica-bundle-cache
EOF

direnv allow .
```

That's it. It would be a good idea to add `.envrc` to gitignore.
