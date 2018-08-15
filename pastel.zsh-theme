#!/bin/env zsh

#Allow Command Substitution in prompt
setopt promptsubst

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_PREFIX="%F{white}(%f"
GIT_PROMPT_SUFFIX="%F{white})%f"

GIT_PROMPT_UNTRACKED="%F{009}%B!%b%f"
GIT_PROMPT_MODIFIED="%F{010}%B+%b%f"
GIT_PROMPT_STAGED="%F{011}%B*%b%f"

EXIT_CODE=" %(?..%F{009}(%?%)%f)"

PR_COLOR="%(?.%F{012}❯%f.%F{009}❯%f)"

# Check the UID
if [[ $UID -ne 0 ]]; then # normal user
  PR_USER="%F{012}%n%f"
else # root
  PR_USER="%F{009}%n%f"
fi

# Show Git branch/tag, or name-rev if on detached head
function parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
function parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE="$GIT_STATE$GIT_PROMPT_UNTRACKED"
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE="$GIT_STATE$GIT_PROMPT_MODIFIED"
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE="$GIT_STATE$GIT_PROMPT_STAGED"
  fi

  if [[ -n $GIT_STATE ]]; then
    echo " $GIT_STATE"
  fi

}

# If inside a Git repository, print its branch and state
function git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo " $GIT_PROMPT_PREFIX%F{white}${git_where#(refs/heads/|tags/)}$(parse_git_state)$GIT_PROMPT_SUFFIX"
}

# Disable default venv
export VIRTUAL_ENV_DISABLE_PROMPT=1

function venv() {

  VENV_SHOW="${VENV_SHOW=true}"
  VENV_PREFIX="${VENV_PREFIX="$PROMPT_DEFAULT_PREFIX"}"
  VENV_SUFFIX="${VENV_SUFFIX="$PROMPT_DEFAULT_SUFFIX"}"
  VENV_SYMBOL="${VENV_SYMBOL=""}"
  # The (A) expansion flag creates an array, the '=' activates word splitting
  VENV_GENERIC_NAMES="${(A)=VENV_GENERIC_NAMES=virtualenv venv .venv}"
  VENV_COLOR="${VENV_COLOR="blue"}"


  # Check if the current directory running via Virtualenv
  [ -n "$VIRTUAL_ENV" ] || return

  local 'venv'

  if [[ "${VENV_GENERIC_NAMES[(i)$VIRTUAL_ENV:t]}" -le \
        "${#VENV_GENERIC_NAMES}" ]]
  then
    venv="$VIRTUAL_ENV:h:t"
  else
    venv="$VIRTUAL_ENV:t"
  fi
  echo "${venv}"
}

# Set Prompt
PROMPT=$'$PR_USER%F{007}@%F{013}%m%f %F{010}[%~]%f$(git_prompt_string) %F{011}$(venv)%f $EXIT_CODE\n$PR_COLOR '
