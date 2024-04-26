ARG RUBY_VERSION=3.3.1

FROM ruby:$RUBY_VERSION-slim

ARG TARGETPLATFORM

RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
          sudo build-essential curl wget vim \
          bzr git mercurial subversion cvs \
          ghostscript \
          gsfonts \
          imagemagick libmagick++-dev \
          libsqlite3-dev \
          libnss3-dev \
    ; \
    # Allow ImageMagick to read PDFs
    sed -ri 's/(rights)="none" (pattern="PDF")/\1="read" \2/' /etc/ImageMagick-6/policy.xml; \
    \
    # Install Node.js and yarn
    curl -fsSL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g yarn; \
    \
    rm -rf /var/lib/apt/lists/*

# Install Google Chrome for system test when the target platform is amd64
RUN set -eux; \
    if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
      echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
      apt-get update && apt-get install -y --no-install-recommends google-chrome-stable; \
      \
      rm -rf /var/lib/apt/lists/*; \
    fi;

# Add a user to run and develop the application.
# In the entrypoint.sh, the UID and GID of this developer user will be set to the same as the host user.
ENV USER_NAME=developer
RUN groupadd $USER_NAME && \
    useradd -d /home/$USER_NAME -m -g $USER_NAME -s /bin/bash $USER_NAME

# Allow general users to use sudo.
RUN echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USER_NAME

RUN mkdir /bundle && chmod -R ugo+rw /bundle
VOLUME /bundle
ENV BUNDLE_PATH="/bundle"

WORKDIR /redmine

ENV BINDING="0.0.0.0"
ENV EDITOR="vim"

# Configure Google Chrome for system test
ENV GOOGLE_CHROME_OPTS_ARGS="headless,disable-gpu,no-sandbox,disable-dev-shm-usage"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

