# syntax=docker/dockerfile:1.7
ARG DEVTOOLS_BASE_IMAGE=ubuntu:22.04
FROM ${DEVTOOLS_BASE_IMAGE}

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

ARG DOTFILES_REPO=https://github.com/bndos/devdotfiles.git
ARG RUN_DEVDOTFILES_INSTALL=0
ARG INSTALL_OH_MY_ZSH=1
ARG OH_MY_ZSH_REPO=https://github.com/ohmyzsh/ohmyzsh.git
ARG ZSH_AUTOSUGGESTIONS_REPO=https://github.com/zsh-users/zsh-autosuggestions.git
ARG ZSH_SYNTAX_HIGHLIGHTING_REPO=https://github.com/zsh-users/zsh-syntax-highlighting.git
ARG INSTALL_EMACS_PLUS=1
ARG EMACS_PLUS_FORMULA=emacs-plus@31
ARG INSTALL_DOOM_EMACS=1
ARG DOOM_REPO=https://github.com/doomemacs/doomemacs.git
ARG DOOM_CONFIG_REPO=https://github.com/bndos/.doom.d.git

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/root/.config/emacs/bin:/root/.cargo/bin:/root/.local/bin:/usr/local/bin:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash-completion \
      build-essential \
      ca-certificates \
      curl \
      cmake \
      fd-find \
      file \
      fonts-powerline \
      git \
      htop \
      jq \
      less \
      libssl-dev \
      libtool \
      libtool-bin \
      libvterm-dev \
      nano \
      nodejs \
      npm \
      openssh-client \
      pkg-config \
      ripgrep \
      sqlite3 \
      sudo \
      tmux \
      unzip \
      vim \
      wget \
      xclip \
      zsh \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN if [[ "${INSTALL_EMACS_PLUS}" == "1" ]]; then \
      useradd --create-home --shell /bin/bash linuxbrew || true; \
      install -d -o linuxbrew -g linuxbrew /home/linuxbrew/.linuxbrew; \
      su linuxbrew -s /bin/bash -c 'NONINTERACTIVE=1 CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'; \
      su linuxbrew -s /bin/bash -c 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew tap d12frosted/emacs-plus && brew install "'"${EMACS_PLUS_FORMULA}"'" --without-cocoa && brew install ripgrep node'; \
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
      EMACS_PLUS_PREFIX="$(brew --prefix "${EMACS_PLUS_FORMULA}")"; \
      ln -sf "${EMACS_PLUS_PREFIX}/bin/emacs" /usr/local/bin/emacs; \
      ln -sf "${EMACS_PLUS_PREFIX}/bin/emacsclient" /usr/local/bin/emacsclient; \
      emacs --version | head -1; \
    else \
      apt-get update && apt-get install -y --no-install-recommends emacs-nox && rm -rf /var/lib/apt/lists/*; \
    fi

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh \
    && uv --version

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
      | sh -s -- -y --profile minimal \
    && source /root/.cargo/env \
    && rustup component add rustfmt clippy \
    && rustc --version \
    && cargo --version

RUN npm install -g emacs-lsp-proxy \
    && emacs-lsp-proxy --version

RUN git clone --depth 1 "${DOTFILES_REPO}" /opt/bndos-devdotfiles \
    && if [[ "${RUN_DEVDOTFILES_INSTALL}" == "1" ]]; then \
         bash /opt/bndos-devdotfiles/install.sh; \
       else \
         echo "Skipping devdotfiles install.sh. Set --build-arg RUN_DEVDOTFILES_INSTALL=1 to run it."; \
       fi

RUN if [[ "${INSTALL_DOOM_EMACS}" == "1" ]]; then \
      rm -rf /root/.config/emacs /root/.config/doom; \
      git clone --depth 1 "${DOOM_REPO}" /root/.config/emacs; \
      git clone --depth 1 "${DOOM_CONFIG_REPO}" /root/.config/doom; \
      sed -i 's/:host "bndos\/persp-mode.el"/:host github :repo "bndos\/persp-mode.el"/' /root/.config/doom/packages.el; \
      /root/.config/emacs/bin/doom install --force --no-env --no-hooks; \
      /root/.config/emacs/bin/doom sync; \
      printf '%s\n' '(doom-startup)' > /root/.config/emacs/init.el; \
      ln -sfn /root/.config/emacs /root/.emacs.d; \
      mkdir -p /root/.config/doom/snippets; \
      VTERM_DIR="$(find /root/.config/emacs/.local/straight -path '*/build-*/vterm' -type d | head -n 1 || true)"; \
      if [[ -n "${VTERM_DIR}" ]]; then \
        cmake -S "${VTERM_DIR}" \
              -B "${VTERM_DIR}/build" \
              -DUSE_SYSTEM_LIBVTERM=yes; \
        cmake --build "${VTERM_DIR}/build" -j"$(nproc)"; \
      fi; \
      emacs --batch --eval '(message "Emacs batch smoke test OK")'; \
      EMACS_BUILD_ROOT="$(find /root/.config/emacs/.local/straight -maxdepth 1 -type d -name 'build-*' | head -n 1 || true)"; \
      test -n "${EMACS_BUILD_ROOT}"; \
      LOAD_PATH_ARGS=(); \
      while IFS= read -r dir; do LOAD_PATH_ARGS+=("-L" "${dir}"); done < <(find "${EMACS_BUILD_ROOT}" -mindepth 1 -maxdepth 1 -type d); \
      emacs --batch "${LOAD_PATH_ARGS[@]}" --eval '(progn (require (quote lsp-proxy)) (unless (executable-find "emacs-lsp-proxy") (error "emacs-lsp-proxy not found")) (message "lsp-proxy smoke test OK: %s" (executable-find "emacs-lsp-proxy")))'; \
      /root/.config/emacs/bin/doom --version; \
      printf '%s\n' \
        '(setq native-comp-deferred-compilation nil)' \
        '(setq native-comp-jit-compilation nil)' \
        '(doom-startup)' \
        > /root/.config/emacs/init.el; \
    else \
      echo "Skipping Doom Emacs install. Set --build-arg INSTALL_DOOM_EMACS=1 to install it."; \
    fi

RUN if [[ "${INSTALL_OH_MY_ZSH}" == "1" ]]; then \
      rm -rf /root/.oh-my-zsh; \
      git clone --depth 1 "${OH_MY_ZSH_REPO}" /root/.oh-my-zsh; \
      git clone --depth 1 "${ZSH_AUTOSUGGESTIONS_REPO}" /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions; \
      git clone --depth 1 "${ZSH_SYNTAX_HIGHLIGHTING_REPO}" /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; \
    else \
      echo "Skipping oh-my-zsh install. Set --build-arg INSTALL_OH_MY_ZSH=1 to install it."; \
    fi

RUN uv tool install basedpyright \
    && uv tool install ruff \
    && uv tool install ty \
    && basedpyright --version \
    && ruff --version \
    && ty --version

RUN cat >/etc/profile.d/bndos-devtools.sh <<'EOF'
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"
export TERM="xterm-256color"
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/root/.config/emacs/bin:/root/.cargo/bin:/root/.local/bin:/usr/local/bin:${PATH}"
EOF

RUN cat >/root/.zshrc <<'EOF'
source /etc/profile.d/bndos-devtools.sh

export ZSH="/root/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

if [ -d "$ZSH" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

mkdir -p /commandhistory 2>/dev/null || true
if [ -d /commandhistory ]; then
  export HISTFILE=/commandhistory/.zsh_history
else
  export HISTFILE=/root/.zsh_history
fi
export HISTSIZE=50000
export SAVEHIST=50000
setopt append_history share_history hist_ignore_all_dups hist_reduce_blanks 2>/dev/null || true
EOF

RUN cat >/root/.bashrc <<'EOF'
source /etc/profile.d/bndos-devtools.sh
mkdir -p /commandhistory 2>/dev/null || true
if [ -d /commandhistory ]; then
  export PROMPT_COMMAND='history -a'
  export HISTFILE=/commandhistory/.bash_history
fi
EOF

CMD ["/bin/zsh"]
