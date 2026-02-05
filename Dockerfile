FROM debian:trixie-20260112


RUN apt-get update && apt-get install -y \
  # LaTeX packages for IEEE and EGU journals
  texlive-base \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-publishers \
  texlive-science \
  texlive-fonts-recommended \
  texlive-bibtex-extra \
  biber \
  # some auxiliary tools
  wget \
  curl \
  git \
  adduser \
  openssh-client \
  make \
  pandoc \
  fig2dev \
  ripgrep \
  fd-find \
  just \
  hunspell  \
  nodejs \
  npm \
  chktex \
  fzf \
  bat \
  zoxide \
  eza \
  default-jre-headless \
  locales && \
  # Removing documentation packages *after* installing them is kind of hacky,
  # but it only adds some overhead while building the image.
  apt-get --purge remove -y '.*-doc' && \
  # Remove more unnecessary stuff
  apt-get clean -y


# Install prek precommit hook
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/j178/prek/releases/download/v0.3.1/prek-installer.sh | sh

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


RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
  locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Configure shell for vscode user
RUN echo '\
  RESET="\\[\\e[0m\\]"\n\
  BOLD="\\[\\e[1m\\]"\n\
  GREEN="\\[\\e[32m\\]"\n\
  BLUE="\\[\\e[34m\\]"\n\
  export PS1="${BLUE}vscode ${BLUE}${BOLD}\\w${RESET} $ "\n\
  eval "$(dircolors -b)"\n\
  eval "$(zoxide init bash)"\n\
  alias ls="eza --group-directories-first"\n\
  alias ll="eza -lh --group-directories-first"\n\
  alias la="eza -lah --group-directories-first"\n\
  alias cat="batcat"\n\
  # Auto-completion for fzf\n\
  source /usr/share/doc/fzf/examples/key-bindings.bash\n\
  source /usr/share/doc/fzf/examples/completion.bash\n\
  ' | tee -a /root/.bashrc >> "$USER_HOME/.bashrc"

# Install uv for both root and vscode user
RUN wget -qO- https://astral.sh/uv/install.sh | sh && \
  su - "$USER_NAME" -c 'wget -qO- https://astral.sh/uv/install.sh | sh'

# install bibtex-tidy
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends npm && \
    /usr/bin/npm install -g bibtex-tidy

# install doi2bib
RUN /root/.local/bin/uv tool install doi2bib