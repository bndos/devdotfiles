#!/usr/bin/env sh
curl https://sh.rustup.rs -sSf | sh

brew install emacs-plus@31 ripgrep
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

rm -rf ~/.config/doom
git clone https://github.com/bndos/.doom.d ~/.config/doom


~/.config/emacs/bin/doom sync
