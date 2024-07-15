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

### Global settings

* `REDMINED_CONTAINER_NAME` Container name for redmined. If not set, use "redmined-container" as default.
* `REDMINED_MAP_HOST_USER_TO_CONTAINER_USER` Map the UID and GID of the host user to the container user
* `REDMINED_BUNDLE_CACHE_VOLUME` Volume name for bundler cache. If not set, use "redmine-bundle-cache" as default.
* `REDMINED_IMAGE` Docker image for redmined. If not set, use "ghcr.io/hidakatsuya/redmined" as default.
* `REDMINED_REDMINE_PORT` Port number for Redmine. If not set, use "3000" as default.
* `REDMINED_CONTAINER_ENVS` Additional environment variables for redmined container. Multiple variables can be set by separating them with a space. If not set, use "" as default.
* `REDMINED_PUBLISH_PORT` Port mapping for Redmine. If not set, use "3000:3000" as default.

See [redmined](https://github.com/hidakatsuya/redmined/blob/main/redmined) for further details.

### Individual settings

You can create the configuration file named `.redmined.json` for different Redmine environments in the Redmine root directory.

```json
{
  "default": {
    "name": "redmine",
    "ruby_version": "3.3",
    "port": "3000",
    "env": {
      "PUMA_MIN_THREADS": 1
    }
  }
}
```

Then, you can use Redmine in the above environment by executing the command as usual. The details of the configuration are as follows:

* `name`: This name determines to the following settings
  * `REDMINED_BUNDLE_CACHE_VOLUME` -> `redmined-<name>-bundle-cache`
  * `REDMINED_CONTAINER_NAME` -> `redmined-<name>-container`
* `ruby_version`: This version determines the container image redmined uses `REDMINED_IMAGE`:ruby<ruby-version>`.
* `port`: This port determines the `--expose` settings of `docker run` and `$PORT` which `rails server` respects
* `env`: This object determines the environment variables for the container

Additionally, you can add the configuration for the different Redmine environment.

```json
{
  "default": {
    "name": "redmine",
    "ruby_version": "3.3"
  },
  "ruby3.2": {
    "name": "redmine-ruby3.2",
    "ruby_version": "3.2",
    "port": "3001"
  }
}
```

The environment added above can be used as follows:

```
redmined -n ruby3.2 bin/rails server
```

## Tips

### Using separate environments for multiple Redmines

You can configure the indivisual settings for different Redmine environments. See [Individual settings](#individual-settings) for further details.

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

### Executing redmined command with modified environment variables

```shell
redmined env RAILS_ENV=development bin/about
```
