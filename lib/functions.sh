#!/usr/bin/env bash

#
# Display and logging utilities
#

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
  printf "➜ $@\n"
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
  exit -1
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
#   $ getback        # get back to $HOME/.emacs.d
#
# @param $1  Directory to make a mark. If omitted, the current
#            directory will be marked.
# @see getback()
mark() {
  local dir="${1:-$(pwd)}"
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
#   $ getback        # get back to $HOME/.emacs.d
# @param $1  Destination directory to change.
# @see mark()
# @see getback()
markcd() {
  local dest="${1}"
  mark
  mkdir -p "${dest}"
  cd "${dest}"
}

# Get back to the top of the directory stack, and remove it from the
# stack.
#
# @see mark()
getback() {
  popd 1>/dev/null
}

# Convert a relative path to an absolute path.
#
# Example usage:
#
#   $ project_path="$(abspath develop/awesome_project)"
#
# @param $1  Relative path to a file or a directory.
# @return  Return its absolute path to stdout.
abspath() {
  if [[ -d "$1" ]]; then
    # dir
    (cd "$1"; pwd)
  elif [[ -f "$1" ]]; then
    # file
    if [[ $1 = /* ]]; then
      echo "$1"
    elif [[ $1 == */* ]]; then
      echo "$(cd "${1%/*}"; pwd)/${1##*/}"
    else
      echo "$(pwd)/$1"
    fi
  else
    e_warning "$1 does not exist."
  fi
}

# Return a path to the parent directory for a given file or directory.
#
# Example usage:
#
#   $ parent="$(parentdir develop/awesome_project)"
#
# @param $1 Path to a file or directory to find its parent directory.
# @return Return its parent directory path to stdout.
parentdir() {
  local path="$(abspath "$1")"
  echo "${path%/*}"
}

# Make a prompt to ask user yes or no question.
#
# Example usage:
#
#   $ if ask "Are you sure?"; then
#   >   echo "Okay!"
#   > else
#   >   echo "Hmmm..."
#   > fi
#   Are you sure? [Y/n] y
#   Okay!
#
# @param $1 prompt  Prompt message.
# @return True (0) if the answer from user is yes,
#         False (>0) if the answer from user is no.
ask() {
  local prompt="${1:-Are you sure?}"
  prompt="${prompt} [y/n] "
  local retval

  echo -n "${prompt}"
  while read -r -n 1 -s answer; do
    if [[ $answer = [YyNn] ]]; then
      [[ $answer = [Yy] ]] && retval=0
      [[ $answer = [Nn] ]] && retval=1
      break
    fi
    echo
    echo "Please answer with y/n."
  done
  echo
  return $retval
}

# Check if a string is contained in a list separated with space.
#
# Example usage:
#
#   $ list="apple banana orange"
#   $ if contains "banana" "$list"; then
#   >   echo "banana is in list."
#   > fi
#
# @param $1 string  String to check.
# @param $2 list    List to be searched.
# @return True(0)  If the string is contained in the list.
#         False(>0) Otherwise.
contains() {
  local string="$1"
  shift
  local list="$@"

  if [[ $list =~ (^|[[:space:]])"$string"($|[[:space:]]) ]]; then
    return 0
  else
    return 1
  fi
}

# Convert a string to a lower-case string.
#
# Example usage:
#
#   $ echo $(lower "Something.")
#   something.
#
# @see upper()
lower() {
  echo "${1,,}"
}

# Convert a string to a upper-case string.
#
# Example usage:
#
#   $ echo $(lower "Something.")
#   SOMETHING.
#
# @see lower()
upper() {
  echo "${1^^}"
}

# Detect the running system. Once this function executed, exported
# variables OS_NAME, OS_VERSION and OS_CODENAME are set. Note that the
# all the results are converted into lower-case strings.
#
# Example usage:
#
#   $ detect_os
#   $ echo $OS_NAME $OS_VERSION $OS_CODENAME
#   ubuntu 18.04 bionic
detect_os() {
  export OS_NAME
  export OS_VERSION
  export OS_CODENAME

  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OS_NAME="$(lower $NAME)"
    OS_VERSION="$VERSION_ID"
    OS_CODENAME="$(lower $VERSION_CODENAME)"
  elif has lsb_release; then
    OS_NAME="$(lower $(lsb_release -si))"
    OS_VERSION="$(lsb_release -sr)"
    OS_CODENAME="$(lower $(lsb_release -sc))"
  elif [[ -f /etc/lsb-release ]]; then
    source /etc/lsb-release
    OS_NAME="$(lower $DISTRIB_ID)"
    OS_VERSION="$DISTRIB_RELEASE"
    OS_CODENAME="$(lower $DISTRIB_CODENAME)"
  else
    OS_NAME="$(lower $(uname -s))"
    OS_VERSION="$(uname -r)"
    OS_CODENAME=
  fi
}

# Compares two version strings and returns the result of comparison as
# an exit-status. The implementation of this function is based on
# https://stackoverflow.com/a/4025065
#
# Example usage:
#
#   $ set +e; compare_ver_string ${BASH_VERSION} 4.2; result=$?; set -e
#   $ if [[ result == 2 ]]; then
#   >   echo "Minimum requirement for bash version is 4.2, abort."
#   >   exit 1
#   > fi
#
# @param $1 ver1  First version string to compare
# @param $2 ver2  Second version string to compare
# @return 0 if the two versions are equal,
#         1 if the first version is bigger,
#         2 if the first version is lower.
compare_ver_string() {
  if [[ $1 == $2 ]]; then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]%%[^0-9]*} > 10#${ver2[i]%%[^0-9]*})); then
      return 1
    fi
    if ((10#${ver1[i]%%[^0-9]*} < 10#${ver2[i]%%[^0-9]*})); then
      return 2
    fi
  done
  return 0
}

# Ask for sudo password and then no more password is required until
# the script ends or calling _reset_sudo.
#
# Example usage:
#
#   $ keep_sudo
#   [sudo] password for user:
#   $ # sudo command to take long time
#   $ reset_sudo
#
# @see _reset_sudo()
# @see https://gist.github.com/cowboy/3118588
keep_sudo() {
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

# Reset timestamp for sudo command.
#
# @see keep_sudo()
reset_sudo() {
  sudo -k
}

#
# Git operations
#

readonly __MSG_GIT_NOT_INSTALLED="Git is not installed on the system."

# Check if the current working directory or a specified directory is a
# Git repository or not.
#
# Example usage:
#
#   $ if is_git_repository; then
#   >   git pull origin master
#   > fi
#
# @param $1  Directory to check if a Git repo.
# @return True (0) if the directory is a Git repo.
#         False (>0) if the  directory is not a Git repo.
is_git_repository() {
  if ! has "git"; then
    e_error "${__MSG_GIT_NOT_INSTALLED}"
    return 1
  fi

  local directory="${1:-.}"
  if [[ ! -d "${directory}" ]]; then
    return 1
  fi

  local retval=0
  mark && cd "${directory}"
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    retval=1
  fi
  getback
  return $retval
}

# Checkout a specified branch with confirmation. This function asks
# the user if surely checking out the branch beforehand.
#
# @param $1  Branch name to checkout.
git_checkout_with_confirm() {
  local dst_branch="${1:-}"
  local cur_branch="$(git branch | grep \* | cut -d ' ' -f2)"

  if [[ -z "${dst_branch}" ]]; then
    e_error "Specify destination branch (${FUNCNAME[0]})"
    return 1
  fi

  if [[ "${cur_branch}" != "${dst_branch}" ]]; then
    if ask "Are you sure to checkout '${dst_branch}'?"; then
      git checkout "${dst_branch}"
    fi
  fi
}

# Pull updates from remote and subsequently updates submodules within
# the repository.
#
# @param $1 branch  Branch name to fetch (default: master)
# @return True (0) if sucessful,
#         False (>0) otherwise.
git_update() {
  if ! has "git"; then
    e_error "${__MSG_GIT_NOT_INSTALLED}"
    return 1
  fi

  local branch="${1:-master}"
  git pull origin "${branch}"
  git submodule init
  git submodule update
  git_checkout_with_confirm "${branch}"
}

# Clone a specified repository from remote at the current directory.
# If the current directory is a Git repository, just pull update.
#
# @param $1 url  Git URL
# @param $2 dest  Directory to clone the repository
# @param $3 branch  Branch name
# @see git_clone_or_update()
_git_clone_or_update() {
  local url="$1"
  local dest="${2:-}"
  local branch="${3:-}"
  local dirname="${url##*/}"
  dirname="${dirname%.git}"

  if [[ -z "${dest}" ]]; then
    dest="${dirname}"
  fi

  if ! is_git_repository "${dest}"; then
    git clone --recursive "${url}" "${dest}"
    if [[ -n "${branch}" ]]; then
      mark && cd "${dest}"
      git_checkout_with_confirm "${branch}"
      getback
    fi
  else
    mark && cd "${dest}"
    git_update "${branch}"
    getback
  fi
}

# Clone a specified repository from remote at a specified location. If
# the repository already exists, pull updates.
#
# Example usage:
#
#   $ git_clone_or_update "https://github.com/atsutahiroshi/dotfiles"
#   $ git_clone_or_update "https://github.com/opencv/opencv" "~/src"
#
# @param $1 url  Git URL.
# @param $2 dest  Directory to clone the repository
# @param $3 branch Branch name to fetch from remote
# @see git_update()
git_clone_or_update() {
  if ! has "git"; then
    e_error "${__MSG_GIT_NOT_INSTALLED}"
    return 1
  fi

  local url="$1"
  local dest="${2:-}"
  local branch="${3:-}"

  if [[ -z "${url}" ]]; then
    e_error "Specify Git URL (_git_clone_or_update)"
    return 1
  fi

  _git_clone_or_update "${url}" "${dest}" "${branch}"
}