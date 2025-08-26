#!/usr/bin/env sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

brew tap d12frosted/emacs-plus
brew install emacs-plus@31 --without-cocoa
brew install ripgrep
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install -y

rm -rf ~/.config/doom
git clone https://github.com/bndos/.doom.d ~/.config/doom


~/.config/emacs/bin/doom sync
