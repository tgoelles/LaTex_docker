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

ARG WGET=wget
ARG GIT=git
ARG SSH=openssh-client
ARG MAKE=make
ARG PANDOC=pandoc
ARG PCITEPROC=pandoc-citeproc
ARG PYGMENTS=python3-pygments
ARG PYTHONIS=python-is-python3
ARG FIG2DEV=fig2dev
ARG JRE=default-jre-headless
ARG SPELL=hunspell

RUN apt-get update && apt-get install -y \
  texlive-full \
  # some auxiliary tools
  "$WGET" \
  "$GIT" \
  "$SSH" \
  "$MAKE" \
  # markup format conversion tool
  "$PANDOC" \
  "$PCITEPROC" \
  # XFig utilities
  "$FIG2DEV" \
  # syntax highlighting package
  "$PYGMENTS" \
  # temporary fix for minted, see https://github.com/gpoore/minted/issues/277
  "$PYTHONIS" \
  # spell checker
  "$SPELL"  \
  # Java runtime environment (e.g. for arara)
  "$JRE" \
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
