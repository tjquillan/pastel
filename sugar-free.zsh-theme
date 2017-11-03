#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
#
# Sugar-free - A simple and minimal theme for oh-my-zsh
#
# Based on my favorite aspects of the Pure and Candy themes,
# as well as some Git-based snippets from <https://gist.github.com/joshdick/4415470>
#
# Pure <https://github.com/sindresorhus/pure>
# Candy <https://github.com/BinaryMuse/oh-my-zsh/blob/master/themes/candy.zsh-theme>
#
# ------------------------------------------------------------------------------

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_PREFIX="%{$fg[white]%}(%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[white]%})%{$reset_color%}"

# These colors match my .gitconfig:
# [color "status"]
#     added = yellow
#     changed = green
#     untracked = cyan
GIT_PROMPT_UNTRACKED="%{$FG[009]%}%B!%b%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$FG[010]%}%B+%b%{$reset_color%}"
GIT_PROMPT_STAGED="%{$FG[011]%}%B*%b%{$reset_color%}"

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

PROMPT=$'%{$FG[012]%}%n%{$FG[007]%}@%{$FG[013]%}%m%{$reset_color%} %{$FG[010]%}[%~]%{$reset_color%} $(git_prompt_string) \
%{$FG[012]%}%{$FG[012]%}❯%{$reset_color%} '
