#!/usr/bin/env bash

# Avoid double sourcing of this file.
set +u
if [[ -n "$__UTILS_SH_INCLUDED__" ]]; then
  set -u
  return
fi
__UTILS_SH_INCLUDED__=yes

# Treat unset variable as an error.
set -u

# Define faces and colors
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)

# Headers and logging
e_header() {
  printf "\n${bold}${purple}==========  %s  ==========${reset}\n" "$@"
}

e_arrow() {
  printf "➜ %s\n" "$@"
}

e_success() {
  printf "${green}✔ %s${reset}\n" "$@"
}

e_error() {
  printf "${red}✖ %s${reset}\n" "$@" 1>&2
}

e_warning() {
  printf "${tan}➜ %s${reset}\n" "$@"
}

e_underline() {
  printf "${underline}${bold}%s${reset}\n" "$@"
}

e_bold() {
  printf "${bold}%s${reset}\n" "$@"
}

e_note() {
  printf "${underline}${bold}${blue}Note:${reset}  ${blue}%s${reset}\n" "$@"
}

e_purple() {
  printf "${purple}%s${reset}" "$@"
}

e_red() {
  printf "${red}%s${reset}" "$@"
}

e_green() {
  printf "${green}%s${reset}" "$@"
}

e_tan() {
  printf "${tan}%s${reset}" "$@"
}

e_blue() {
  printf "${blue}%s${reset}" "$@"
}

# Exits the script with an error code.
abort() {
  e_error "$@"
  exit 1
}

# Check if a command is installed or available on the $PATH
# environment variable.
#
# Example usage:
#
#   $ if ! has some_command; then
#   >   echo "some_command is required."
#   > fi
#
# @param $1 Command to check if it exists.
# @return True (0) if the command is installed,
#         False (>0) if the command is not available.
has() {
  type "$1" >/dev/null 2>&1
}

# Add a directory to the top of the directory stack. NOTE: This
# function does not change the current working directory.
#
# Example usage:
#
#   $ cd $HOME/.emacs.d
#   $ mark           # mark here
#   $ cd straight/
#   $ cd repos/
#   $ back        # get back to $HOME/.emacs.d
#
# @param $1  Directory to make a mark. If omitted, the current
#            directory will be marked.
# @see back()
# shellcheck disable=SC2120
mark() {
  local dir

  dir="${1:-$(pwd)}"
  pushd -n "$dir" 1>/dev/null
}

# Mark the current directory and change it to the destination. If the
# destination does not exist, make that directory.
#
# Example usage:
#
#   $ cd $HOME/.emacs.d
#   $ mark_cd straight
#   $ cd repos
#   $ back        # get back to $HOME/.emacs.d
# @param $1  Destination directory to change.
# @see mark()
# @see back()
markcd() {
  local dest

  dest="$1"
  mark "$(pwd)"
  mkdir -p "$dest"
  cd "$dest" || return 1
}

# Get back to the top of the directory stack, and remove it from the
# stack.
#
# @see mark()
back() {
  popd 1>/dev/null || return 1
}
