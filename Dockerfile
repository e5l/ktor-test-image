# syntax=docker/dockerfile:1
# check=skip=FromPlatformFlagConstDisallowed
FROM --platform=linux/amd64 eclipse-temurin:21-jdk-noble

ENV JDK_21_0=$JAVA_HOME

COPY chrome-dependencies.txt /tmp/chrome-dependencies.txt

RUN <<EOT bash
  set -exo pipefail

  # Add Adoptium repository to download Eclipse Temurin JDK
  # https://adoptium.net/installation/linux/#_deb_installation_on_debian_or_ubuntu
  wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
  echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

  # Make apt-get non-interactive
  export DEBIAN_FRONTEND=noninteractive

  # Headless Chrome & Ktor dependencies
  # https://pptr.dev/guides/system-requirements
  # https://github.com/ktorio/ktor/blob/main/CONTRIBUTING.md#building-the-project
  apt-get update
  apt-get install --yes --no-install-recommends \
    git unzip curl wget ca-certificates \
    $(grep --invert-match '^#' /tmp/chrome-dependencies.txt | tr '\n' ' ') \
    libcurl4-openssl-dev libncurses-dev libatomic1 \
    temurin-8-jdk
  apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/chrome-dependencies.txt
EOT
