ARG RUBY_VERSION=4.0

FROM ruby:$RUBY_VERSION-slim-trixie

ARG TARGETPLATFORM
ARG PANDOC_VERSION=3.9.0.2

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

# Install pandoc from the official GitHub Release .deb, following
# https://github.com/jgm/pandoc/blob/main/INSTALL.md#linux.
RUN set -eux; \
    case "${TARGETPLATFORM:-linux/amd64}" in \
      "linux/amd64") architecture="amd64" ;; \
      "linux/arm64") architecture="arm64" ;; \
      *) echo "Unsupported TARGETPLATFORM: ${TARGETPLATFORM}" >&2; exit 1 ;; \
    esac; \
    pandoc_package="pandoc-${PANDOC_VERSION}-1-${architecture}.deb"; \
    curl -fL "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/${pandoc_package}" -o "/tmp/${pandoc_package}"; \
    dpkg -i "/tmp/${pandoc_package}"; \
    rm -f "/tmp/${pandoc_package}"

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
