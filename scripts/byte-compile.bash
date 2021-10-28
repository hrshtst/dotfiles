#!/usr/bin/env bash

set -e
set -o pipefail

(emacs --batch \
       --eval "(setq straight-safe-mode t)"                  \
       --load "$HOME/.emacs.d/init.el"                       \
       --funcall arche-batch-byte-compile 2>&1               \
     | (grep -v "In toplevel form"                  || true) \
     | (grep -v "In end of data"                    || true) \
     | (grep -v "Warning: Package cl is deprecated" || true) \
     | (grep -v "Warning: docstring wider than 80 characters" || true) \
     | (! grep .)) || (rm -f emacs/arche.elc; false)
