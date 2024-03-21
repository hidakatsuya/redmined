ARG RUBY_VERSION=3.3.0

FROM ruby:$RUBY_VERSION-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo \
      bzr git mercurial subversion \
      gsfonts \
      imagemagick libmagick++-dev \
      build-essential libpq-dev libclang-dev \
      vim less locales locales-all \
      default-libmysqlclient-dev libsqlite3-dev \
      ; \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*;

WORKDIR /redmine

ENV USER_NAME=developer

# Allow general users to use sudo.
RUN echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USER_NAME

# Temporary allow general users to add users and groups. This will be reverted in the entrypoint.
RUN chmod u+s /usr/sbin/useradd && chmod u+s /usr/sbin/groupadd

RUN mkdir /bundle && chmod -R ugo+rw /bundle
VOLUME /bundle
ENV BUNDLE_PATH="/bundle"

ENV BINDING="0.0.0.0"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

