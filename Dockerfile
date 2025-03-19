FROM debian:stable-20250317

ARG USER_NAME=vscode
ARG USER_HOME=/home/vscode
ARG USER_ID=1000
ARG USER_GECOS=vscode

RUN adduser \
  --home "$USER_HOME" \
  --uid $USER_ID \
  --gecos "$USER_GECOS" \
  --disabled-password \
  "$USER_NAME"


RUN apt-get update && apt-get install -y \
  texlive-full \
  # some auxiliary tools
  wget \
  curl \
  git \
  openssh-client \
  make \
  pandoc \
  fig2dev \
  hunspell  \
  default-jre-headless \
  locales && \
  # Removing documentation packages *after* installing them is kind of hacky,
  # but it only adds some overhead while building the image.
  apt-get --purge remove -y .\*-doc$ && \
  # Remove more unnecessary stuff
  apt-get clean -y

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
  locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo '\
  RESET="\\[\\e[0m\\]"\n\
  BOLD="\\[\\e[1m\\]"\n\
  GREEN="\\[\\e[32m\\]"\n\
  BLUE="\\[\\e[34m\\]"\n\
  export PS1="${BLUE}vscode ${BLUE}${BOLD}\\w${RESET} $ "\n\
  export LS_OPTIONS="--color=auto"\n\
  eval "$(dircolors -b)"\n\
  alias ls="ls $LS_OPTIONS"\n\
  ' >> /root/.bashrc

# Install uv
RUN wget -qO- https://astral.sh/uv/install.sh | sh
