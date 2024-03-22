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

ENV USER_NAME=developer
RUN groupadd $USER_NAME && \
    useradd -d /home/$USER_NAME -m -g $USER_NAME -s /bin/bash $USER_NAME

# Allow general users to use sudo.
RUN echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USER_NAME

RUN mkdir /bundle && chmod -R ugo+rw /bundle
VOLUME /bundle
ENV BUNDLE_PATH="/bundle"

ENV BINDING="0.0.0.0"

USER $USER_NAME
WORKDIR /redmine

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

