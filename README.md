# devdotfiles

Personal development bootstrap files and reusable container tooling.

## Devtools Image

This repo owns the reusable development tools layer used by project-specific
containers. It includes:

- Emacs 31 from `emacs-plus@31`
- Doom Emacs with `https://github.com/bndos/.doom.d`
- `emacs-lsp-proxy`
- Python editor tools: `basedpyright`, `ruff`, `ty`
- Rust via rustup with `rustfmt` and `clippy`
- zsh, oh-my-zsh, agnoster, autosuggestions, syntax highlighting
- common shell tools such as `git`, `ripgrep`, `fd`, `jq`, `tmux`, `vim`

Build locally:

```bash
scripts/build_devtools_image.sh
```

Default tags:

```text
ghcr.io/bndos/devtools:emacs31-ubuntu22.04
bndos-devtools:emacs31-ubuntu22.04
```

The GitHub Actions workflow publishes the GHCR tag when the image definition
changes on `main`.
