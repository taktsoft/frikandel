# [Choice] Ruby version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.1, 3.0, 2, 2.7, 2.6, 3-bullseye, 3.1-bullseye, 3.0-bullseye, 2-bullseye, 2.7-bullseye, 2.6-bullseye, 3-buster, 3.1-buster, 3.0-buster, 2-buster, 2.7-buster, 2.6-buster
ARG VARIANT=3-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/ruby:0-${VARIANT}

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends vim

# [Optional] Uncomment this line to install additional gems.
# RUN gem install <your-gem-names-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

# # Install exact ruby version and gems. NOTE: `rvm use` is necessary here, so
# # that the gems are detected as installed when using the VSCode Terminal later.
# # (Running `gem install` or `bundle install` without `rvm use` first, will
# # install the gems in a different directory than expected by rvm.)
# ARG EXACT_RUBY_VERSION=…
# RUN su vscode -c "source /usr/local/rvm/scripts/rvm && rvm install ruby ${EXACT_RUBY_VERSION}" 2>&1
# ARG BUNDLER_VERSION=…
# RUN su vscode -c "source /usr/local/rvm/scripts/rvm && rvm use ${EXACT_RUBY_VERSION} && gem install bundler:${BUNDLER_VERSION}" 2>&1

# NOTE: Set all the ARGs in `.devcontainer/devcontainer.json`, because some are
# already set that way.
