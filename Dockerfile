ARG RUBY_VERSION=4.0

FROM ruby:$RUBY_VERSION-slim-trixie

ARG TARGETPLATFORM

RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo build-essential curl wget vim \
    bzr git mercurial subversion cvs \
    fonts-dejavu-core fonts-dejavu-extra \
    ghostscript \
    gsfonts \
    imagemagick libmagick++-dev \
    libsqlite3-dev \
    libpq-dev \
    default-mysql-client \
    libnss3-dev \
    libyaml-dev \
    libclang-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js and yarn
RUN set -eux; \
    curl -fsSL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

# Install Chromium/Chromedriver for system test
RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends chromium chromium-driver && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/bin/chromium /usr/bin/google-chrome && \
    ln -sf /usr/lib/chromium/chromedriver /usr/local/bin/chromedriver

# Add a user to run and develop the application.
# In the entrypoint.sh, the UID and GID of this developer user will be set to the same as the host user.
ENV USER_NAME=developer
RUN groupadd $USER_NAME && \
    useradd -d /home/$USER_NAME -m -g $USER_NAME -s /bin/bash $USER_NAME

# Allow general users to use sudo.
RUN echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USER_NAME

VOLUME /bundle
ENV BUNDLE_PATH="/bundle"

WORKDIR /redmine

ENV BINDING="0.0.0.0"
ENV EDITOR="vim"

# Configure Google Chrome for system test
ENV GOOGLE_CHROME_OPTS_ARGS="headless,disable-gpu,no-sandbox,disable-dev-shm-usage"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
