# Redmined

A docked CLI for Redmine development environment. Inspired by [rails/docked](https://github.com/rails/docked).

[![Build](https://github.com/hidakatsuya/redmined/actions/workflows/test-and-build.yml/badge.svg)](https://github.com/hidakatsuya/redmined/actions/workflows/test-and-build.yml)

## Features

* Requires only Docker CLI
* Supports running most Redmine tests
* CLI can be executed in subdirectories
* Supports multiple Redmine development environments

## Prerequisites

* Source code of [Redmine](https://github.com/redmine/redmine) or its distribution such as [RedMica](https://github.com/redmica/redmica)
* Docker

## Installation

Download [redmined](./redmined) and place it in a location in your PATH, such as `~/.local/bin/`, and grant execution permission.

Or, you can install it directly by running the following commands.

```shell
wget -qO- https://raw.githubusercontent.com/hidakatsuya/redmined/main/install.sh | sh
```
Or
```shell
curl -sSL https://raw.githubusercontent.com/hidakatsuya/redmined/main/install.sh | sh
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

> [!TIP]
> I recommend you define a short command, such as `r`, as an alias for `redmined` command.

## Settings

### Global settings

* `REDMINED_CONTAINER_NAME` Container name for redmined. If not set, use "redmined-container" as default.
* `REDMINED_MAP_HOST_USER_TO_CONTAINER_USER` Map the UID and GID of the host user to the container user
* `REDMINED_BUNDLE_CACHE_VOLUME` Volume name for bundler cache. If not set, use "redmine-bundle-cache" as default.
* `REDMINED_IMAGE` Docker image for redmined. If not set, use "ghcr.io/hidakatsuya/redmined" as default.
* `REDMINED_REDMINE_PORT` Port number for Redmine. If not set, use "3000" as default.
* `REDMINED_CONTAINER_ENVS` Additional environment variables for redmined container. Multiple variables can be set by separating them with a space. If not set, use "" as default.
* `REDMINED_PUBLISH_PORT` Port mapping for Redmine. If not set, use "3000:3000" as default.
* `REDMINED_PLATFORM` Platform for the container image redmined uses.
* `REDMINED_NO_TTY` Whether to run the container in non-TTY mode. If not set, disable non-TTY mode. No TTY mode is also enabled by `-T` opeion of redmined command.

See [redmined](https://github.com/hidakatsuya/redmined/blob/main/redmined) for further details.

### Individual settings

You can create the configuration file named `.redmined.json` for different Redmine environments in the Redmine root directory.

```json
{
  "default": {
    "name": "redmine",
    "ruby": "3.3",
    "port": "3000",
    "env": {
      "PUMA_MIN_THREADS": 1
    }
  }
}
```

Then, you can use Redmine in the above environment by executing the command as usual. The details of the configuration are as follows:

* `name`: It determines to the following settings
  * `REDMINED_BUNDLE_CACHE_VOLUME=redmined-<name>-bundle-cache`
  * `REDMINED_CONTAINER_NAME=redmined-<name>-container`
* `ruby`: It determines the container image redmined uses
  * `REDMINED_IMAGE=REDMINED_IMAGE:ruby<ruby>`
* `port`: It determines the `--expose` settings of `docker run` and `$PORT` which `rails server` respects
  * `REDMINED_REDMINE_PORT=<port>`
  * `REDMINED_PUBLISH_PORT=<port>:<port>`
* `env`: It determines additional environment variables for the redmined container
  * `REDMINED_CONTAINER_ENVS=values of <env>`
* `platform`: It determines the platform of the container image redmined uses
  * `REDMINED_PLATFORM=<platform>`

Additionally, you can add the configuration for the different Redmine environment.

```json
{
  "default": {
    "name": "redmine",
    "ruby": "3.3"
  },
  "ruby3.2": {
    "name": "redmine-ruby3.2",
    "ruby": "3.2",
    "port": "3001"
  }
}
```

The environment added above can be used as follows:

```
redmined -n ruby3.2 bin/rails server
```

## Redmind CLI

```
$ redmined
Usage: redmined [options] [command]

Command:
  Commands to run in the container

Options:
  -n NAME  Specify the configuration name to load from the configuration file
  -T       Run the commands in non-TTY mode
  -c       Print the contents of the configuration file
  -u       Update the redmined script itself and the redmined images to the latest version

Examples:
  redmined bundle install
  redmined bash
  redmined bin/rails server
  redmined -n any-config bundle show
  redmined -T bin/rails test
  redmined -c
  redmined -u
```

## Advanced Usage and Tips

### Updating the redmined CLI and the redmined images

You can update the redmined CLI and the redmined images by executing `redmined -u`.

```shell
$ redmined -u
Updating redmined...
Installed redmined to /home/hidakatsuya/.local/bin

Updating redmined images...
ghcr.io/hidakatsuya/redmined:latest
ghcr.io/hidakatsuya/redmined:ruby3.3
```

### Executing with non-TTY mode

You can execute the command with non-TTY mode by using the `-T` option.

```shell
redmined -T bundle install
```

Or, you can set the environment variable `REDMINED_NO_TTY` to enable non-TTY mode.

```shell
export REDMINED_NO_TTY=1
redmined bundle install
```

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
