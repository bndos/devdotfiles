#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
DEVTOOLS_BASE_IMAGE=${DEVTOOLS_BASE_IMAGE:-ubuntu:22.04}
DEVTOOLS_IMAGE_TAG=${DEVTOOLS_IMAGE_TAG:-ghcr.io/bndos/devtools:emacs31-ubuntu22.04}
LOCAL_IMAGE_TAG=${LOCAL_IMAGE_TAG:-bndos-devtools:emacs31-ubuntu22.04}
DOTFILES_REPO=${DOTFILES_REPO:-https://github.com/bndos/devdotfiles.git}
RUN_DEVDOTFILES_INSTALL=${RUN_DEVDOTFILES_INSTALL:-0}
INSTALL_OH_MY_ZSH=${INSTALL_OH_MY_ZSH:-1}
OH_MY_ZSH_REPO=${OH_MY_ZSH_REPO:-https://github.com/ohmyzsh/ohmyzsh.git}
ZSH_AUTOSUGGESTIONS_REPO=${ZSH_AUTOSUGGESTIONS_REPO:-https://github.com/zsh-users/zsh-autosuggestions.git}
ZSH_SYNTAX_HIGHLIGHTING_REPO=${ZSH_SYNTAX_HIGHLIGHTING_REPO:-https://github.com/zsh-users/zsh-syntax-highlighting.git}
INSTALL_EMACS_PLUS=${INSTALL_EMACS_PLUS:-1}
EMACS_PLUS_FORMULA=${EMACS_PLUS_FORMULA:-emacs-plus@31}
INSTALL_DOOM_EMACS=${INSTALL_DOOM_EMACS:-1}
DOOM_REPO=${DOOM_REPO:-https://github.com/doomemacs/doomemacs.git}
DOOM_CONFIG_REPO=${DOOM_CONFIG_REPO:-https://github.com/bndos/.doom.d.git}

cd "${REPO_ROOT}"
docker build \
  --pull=false \
  --build-arg DEVTOOLS_BASE_IMAGE="${DEVTOOLS_BASE_IMAGE}" \
  --build-arg DOTFILES_REPO="${DOTFILES_REPO}" \
  --build-arg RUN_DEVDOTFILES_INSTALL="${RUN_DEVDOTFILES_INSTALL}" \
  --build-arg INSTALL_OH_MY_ZSH="${INSTALL_OH_MY_ZSH}" \
  --build-arg OH_MY_ZSH_REPO="${OH_MY_ZSH_REPO}" \
  --build-arg ZSH_AUTOSUGGESTIONS_REPO="${ZSH_AUTOSUGGESTIONS_REPO}" \
  --build-arg ZSH_SYNTAX_HIGHLIGHTING_REPO="${ZSH_SYNTAX_HIGHLIGHTING_REPO}" \
  --build-arg INSTALL_EMACS_PLUS="${INSTALL_EMACS_PLUS}" \
  --build-arg EMACS_PLUS_FORMULA="${EMACS_PLUS_FORMULA}" \
  --build-arg INSTALL_DOOM_EMACS="${INSTALL_DOOM_EMACS}" \
  --build-arg DOOM_REPO="${DOOM_REPO}" \
  --build-arg DOOM_CONFIG_REPO="${DOOM_CONFIG_REPO}" \
  -f docker/devtools.Dockerfile \
  -t "${DEVTOOLS_IMAGE_TAG}" \
  -t "${LOCAL_IMAGE_TAG}" \
  .

echo "Built ${DEVTOOLS_IMAGE_TAG} and ${LOCAL_IMAGE_TAG} from ${DEVTOOLS_BASE_IMAGE}."
