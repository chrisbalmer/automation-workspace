# Based off of other themes from oh-my-zsh

local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"


if [[ $UID -eq 0 ]]; then
    local user_host='%{$terminfo[bold]$fg[red]%}%n@%m%{$reset_color%}'
    local user_symbol='#'
else
    local user_host='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
    local user_symbol='$'
fi

local current_dir='%{$terminfo[bold]$fg[blue]%}%~%{$reset_color%}'
local git_branch='$(git_prompt_info)%{$reset_color%}'


time_enabled="%(?.%{$fg[green]%}.%{$fg[red]%})[%D{%Y-%m-%d %H:%M:%S}]%{$reset_color%}"
time_disabled="%{$fg[green]%}[%D{%Y-%m-%d %H:%M:%S}]%{$reset_color%}"
time=$time_enabled

PROMPT="╭─${time} ${user_host} ${current_dir}
╰─%B${user_symbol}%b "
RPS1="%B${return_code}%b"

# ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
# ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"

