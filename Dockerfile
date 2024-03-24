ARG RUBY_VERSION=3.3.0

FROM ruby:$RUBY_VERSION-slim

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
    apt-get install -y nodejs && \
    npm install -g yarn; \
    \
    # Install Google Chrome for system test
    curl -fsSL -o /tmp/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y /tmp/google-chrome-stable.deb; \
    \
    rm /tmp/google-chrome-stable.deb && rm -rf /var/lib/apt/lists/*

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

ENV BINDING="0.0.0.0"

USER $USER_NAME
WORKDIR /redmine

# Configure Google Chrome for system test
ENV GOOGLE_CHROME_OPTS_ARGS="headless,disable-gpu,no-sandbox,disable-dev-shm-usage"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

