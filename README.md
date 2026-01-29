# Redmined

A dockerized CLI for the Redmine development environment. Inspired by [rails/docked](https://github.com/rails/docked).

[![Test](https://github.com/hidakatsuya/redmined/actions/workflows/test.yml/badge.svg)](https://github.com/hidakatsuya/redmined/actions/workflows/test.yml)

## Features

* Provides a reproducible Redmine development environment anywhere
* Requires only Redmine source code and Docker
* Supports multiple environments with different Ruby versions, custom ports, and configurable environment variables
* Can be executed from any subdirectory of the Redmine source code

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

Create the SQLite database configuration by running the following command to generate a `config/database.yml`.

```shell
redmined -d
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

> [!TIP]
> I recommend you define a short command, such as `r`, as an alias for `redmined` command.
>
> ```
> $ r bundle
> $ r bin/rails s
> ```

## Supported Versions

* **Redmine**: Tested with the latest `master` branch of [redmine/redmine](https://github.com/redmine/redmine)
* **Ruby**: Supports Ruby 3.2, 3.3, 3.4, 4.0

## Supported OCI runtimes

* Docker
* [Apple container](https://github.com/apple/container) (Experimental)

## Settings

### Global settings

* `REDMINED_USE_APPLE_CONTAINER` (Experimental) Use Apple container CLI. If not set, do not use Apple container CLI.
* `REDMINED_CONTAINER_NAME` Container name for redmined. If not set, use "redmined-container" as default.
* `REDMINED_MAP_HOST_USER_TO_CONTAINER_USER` Map the UID and GID of the host user to the container user
* `REDMINED_BUNDLE_CACHE_VOLUME` Volume name for bundler cache. If not set, use "redmine-bundle-cache" as default.
* `REDMINED_IMAGE` Docker image for redmined. If not set, use "ghcr.io/hidakatsuya/redmined" as default.
* `REDMINED_RUBY` Ruby version for redmined. If set and REDMINED_IMAGE does not contain the image tag, set the image tag to "ruby<REDMINED_RUBY>".
* `REDMINED_REDMINE_PORT` Port number for Redmine. If not set, use "3000" as default.
* `REDMINED_CONTAINER_ENVS` Additional environment variables for redmined container. Multiple variables can be set by separating them with a space. If not set, use "" as default.
* `REDMINED_PUBLISH_PORT` Port mapping for Redmine. If not set, use "3000:3000" as default.
* `REDMINED_PLATFORM` Platform for the Redmine container image. If you're using Docker, use the format like 'linux/amd64' or 'linux/arm64.' Otherwise, if you're using the Apple container CLI, you can simply use 'amd64' or 'arm64.'.
* `REDMINED_NO_TTY` Whether to run the container in non-TTY mode. If not set, disable non-TTY mode. No TTY mode is also enabled by `-T` opeion of redmined command.
* `REDMINED_NETWORK` Network for the Docker container. If not set, use "" as default.

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
* `image`: It determines the container image redmined uses
  * `REDMINED_IMAGE=<image>`
* `ruby`: It determines the container image redmined uses
  * `REDMINED_IMAGE=REDMINED_IMAGE:ruby<ruby>`
* `port`: It determines the `--expose` settings of `docker run` and `$PORT` which `rails server` respects
  * `REDMINED_REDMINE_PORT=<port>`
  * `REDMINED_PUBLISH_PORT=<port>:<port>`
* `env`: It determines additional environment variables for the redmined container
  * `REDMINED_CONTAINER_ENVS=values of <env>`
* `platform`: It determines the platform of the container image redmined uses
  * `REDMINED_PLATFORM=<platform>`
* `network`: It determines the network of the container image redmined uses
  * `REDMINED_NETWORK=<network>`

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

### Resetting the installed gems

The gems installed by `redmined bundle install` are stored in the docker volume.
You can check the name of the docker volume by the following way.

If there is the `.redmined.json` file in the Redmine root directory, the docker volume name is `redmined-bundle-cache-<name of the current configuration>`, otherwise, it is `redmine-bundle-cache`.

After that, you can remove the docker volume by the following command.

```shell
docker volume rm <the docker volume name>
```

## Redmind CLI

```
Usage: redmined [options] [command]

Command:
  Commands to run in the container

Options:
  -n NAME  Specify the configuration name to load from the configuration file
  -T       Run the commands in non-TTY mode
  -c       Print the contents of the configuration file
  -u       Update the redmined script itself and the redmined images to the latest version
  -d       Create a SQLite database configuration file

Examples:
  Run commands in the container.
  $ redmined ruby -v
  ruby 3.3.4 (2024-07-09 revision be1089c8ec) [x86_64-linux]

  $ redmined bundle install
  Fetching gem metadata from https://rubygems.org/...
  ...

  Enter the container through the bash shell.
  $ redmined bash
  developer@7cc80c9cd1f7:/redmine$

  Launch the Redmine server.
  $ redmined bin/rails server
  => Booting Puma
  => Rails 7.2.1 application starting in development
  => Run `bin/rails server --help` for more startup options
  Puma starting in single mode...
  * Puma version: 6.4.2 (ruby 3.3.4-p94) ("The Eagle of Durango")
  *  Min threads: 0
  *  Max threads: 5
  *  Environment: development
  *          PID: 1
  * Listening on http://0.0.0.0:3000
  Use Ctrl-C to stop

  Run the comands on the "any-config" configuration in the .redmined.json.
  $ redmined -n any-config bundle show

  Run the commands in non-TTY mode.
  $ redmined -T bin/rails test

  Print the contents of the .redmined.json.
  $ redmined -c
  {
    "default": {
      "name": "redmica",
      "port": "3001"
    },
    "ruby3.2": {
      "name": "redmica-ruby3.2",
      "ruby": "3.2"
    }
  }

  Update the redmined script itself and the redmined images to the latest version.
  $ redmined -u
  Updating redmined...
  Installed redmined to /home/hidakatsuya/.local/bin

  Updating redmined images...
  ghcr.io/hidakatsuya/redmined:latest
  ghcr.io/hidakatsuya/redmined:ruby3.3
```
