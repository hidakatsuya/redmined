# Redmined

A Dockerized CLI for provisioning Redmine development environment. Inspired by [rails/docked](https://github.com/rails/docked).

## Prerequisites

* Source code of [Redmine](https://github.com/redmine/redmine) or its distribution such as [RedMica](https://github.com/redmica/redmica)
* Docker

## Installation

Define the `redmined` command with the following code:

```bash
function redmined() {
  local image_name="ghcr.io/hidakatsuya/redmined"
  local container_name="redmined-container"
  local bundle_volume_name="redmine-bundle-cache"

  # Create a Docker volume for the bundle cache if it doesn't exist.
  if [ ! $(docker volume ls -q -f name=$bundle_volume_name) ]; then
    docker volume create $bundle_volume_name > /dev/null
  fi

  # Run the container if it's not running, otherwise exec into it.
  if [ ! $(docker ps -q --filter name=$container_name) ]; then
    docker run --name $container_name --rm -it \
      -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) \
      -v ${PWD}:/redmine -v $bundle_volume_name:/bundle \
      -p 3000:3000 $image_name $@
  else
    docker exec -it $container_name $@
  fi
}
```

## Usage

```
cd your-redmine-root-directory

redmined bin/rails db:migrate
redmined bin/rails s
```
