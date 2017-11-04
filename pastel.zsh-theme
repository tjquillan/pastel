#!/usr/bin/env zsh

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_PREFIX="%F{white}(%f"
GIT_PROMPT_SUFFIX="%F{white})%f"

GIT_PROMPT_UNTRACKED="%F{009}%B!%b%f"
GIT_PROMPT_MODIFIED="%F{010}%B+%b%f"
GIT_PROMPT_STAGED="%F{011}%B*%b%f"

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo " $GIT_STATE"
  fi

}

# If inside a Git repository, print its branch and state
git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$GIT_PROMPT_PREFIX%{$fg[white]%}${git_where#(refs/heads/|tags/)}$(parse_git_state)$GIT_PROMPT_SUFFIX"
}

# Set Prompt
PROMPT=$'%F{012}%n%F{007}@%F{013}%m%f %F{010}[%~]%f $(git_prompt_string) \
%F{012}❯%f '