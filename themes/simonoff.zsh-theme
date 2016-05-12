# Prompt
#
# Below are the color init strings for the basic file types. A color init
# string consists of one or more of the following numeric codes:
# Attribute codes:
# 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white
function precmd {

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))


    ###
    # Truncate the path if it's too long.

    PR_FILLBAR=""
    PR_PWDLEN=""

    local promptsize=${#${(%):---(%n@%M:%l)---()--}}
    local pwdsize=${#${(%):-%~}}
    local gitbranch="$(git_prompt_info)"
    local gitbranchsize=${#${gitbranch}}
    local rubyprompt=`rvm_prompt_info || rbenv_prompt_info`
    local rubypromptsize=${#${rubyprompt}}

    if [[ "$promptsize + $pwdsize + $rvmpromptsize + $gitbranchsize" -gt $TERMWIDTH ]]; then
        ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
        PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $pwdsize + $rvmpromptsize + $gitbranchsize)))..${PR_HBAR}.)}"
    fi
}


setopt extended_glob

preexec () {
    if [[ "$TERM" == "screen" ]]; then
        local CMD=${1[(wr)^(*=*|sudo|-*)]}
        echo -n "\ek$CMD\e\\"
    fi

    if [[ "$TERM" == "xterm" ]]; then
        print -Pn "\e]0;$1\a"
    fi

    if [[ "$TERM" == "rxvt" ]]; then
        print -Pn "\e]0;$1\a"
    fi

}

setprompt () {
    ###
    # Need this so the prompt will work.

    setopt prompt_subst


    ###
    # See if we can use colors.

    autoload zsh/terminfo
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"


    ###
    # See if we can use extended characters to look nicer.
    # UTF-8 Fixed

    if [[ $(locale charmap) == "UTF-8" ]]; then
        PR_SET_CHARSET=""
        PR_SHIFT_IN=""
        PR_SHIFT_OUT=""
        PR_HBAR="─"
        PR_ULCORNER="┌"
        PR_LLCORNER="└"
        PR_LRCORNER="┘"
        PR_URCORNER="┐"
    else
        typeset -A altchar
        set -A altchar ${(s..)terminfo[acsc]}
        # Some stuff to help us draw nice lines
        PR_SET_CHARSET="%{$terminfo[enacs]%}"
        PR_SHIFT_IN="%{$terminfo[smacs]%}"
        PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
        PR_HBAR='$PR_SHIFT_IN${altchar[q]:--}$PR_SHIFT_OUT'
        PR_ULCORNER='$PR_SHIFT_IN${altchar[l]:--}$PR_SHIFT_OUT'
        PR_LLCORNER='$PR_SHIFT_IN${altchar[m]:--}$PR_SHIFT_OUT'
        PR_LRCORNER='$PR_SHIFT_IN${altchar[j]:--}$PR_SHIFT_OUT'
        PR_URCORNER='$PR_SHIFT_IN${altchar[k]:--}$PR_SHIFT_OUT'
     fi

    ###
    # Modify Git prompt
    ZSH_THEME_GIT_PROMPT_PREFIX=" ["
    ZSH_THEME_GIT_PROMPT_SUFFIX="]"
    ###
    # Modify RVM prompt
    ZSH_THEME_RVM_PROMPT_PREFIX=" ["
    ZSH_THEME_RVM_PROMPT_SUFFIX="]"


###
# Decide if we need to set titlebar text.

    case $TERM in
    xterm*|*rxvt*)
        PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%M:%~ $(git_prompt_info) $(rvm_prompt_info) | ${COLUMNS}x${LINES} | %y\a%}'
        ;;
    screen)
        PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
        ;;
    *)
        PR_TITLEBAR=''
        ;;
    esac


###
# Decide whether to set a screen title
    if [[ "$TERM" == "screen" ]]; then
        PR_STITLE=$'%{\ekzsh\e\\%}'
    else
        PR_STITLE=''
    fi

###
# Finally, the prompt.
#
    PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}$PR_RED$PR_ULCORNER$PR_HBAR<$PR_BLUE%(!.$PR_RED%SROOT%s.%n)$PR_GREEN@$PR_BLUE%M:$PR_GREEN%$PR_PWDLEN<...<%~%<<$PR_CYAN${gitbranch}${rubyprompt}$PR_RED>$PR_HBAR$PR_HBAR${(e)PR_FILLBAR}$PR_HBAR<$PR_GREEN%l$PR_RED>$PR_HBAR$PR_URCORNER$PR_NO_COLOUR
$PR_RED$PR_LLCORNER$PR_RED$PR_HBAR<%(?..$PR_LIGHT_RED%?$PR_BLUE:)$PR_LIGHT_BLUE%(!.$PR_RED.$PR_WHITE)%#$PR_RED>$PR_HBAR$PR_NO_COLOUR'

    # display exitcode on the right when >0
    return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"
    RPROMPT=' $return_code$PR_RED$PR_HBAR<$PR_YELLOW%D{%d %b, %a}$PR_RED>$PR_HBAR$PR_LRCORNER$PR_NO_COLOUR'

    PS2='$PR_RED$PR_HBAR<%(?..$PR_LIGHT_RED%?$PR_BLUE:)$PR_LIGHT_BLUE%(!.$PR_RED.$PR_WHITE)%#$PR_RED>$PR_HBAR$PR_NO_COLOUR '
}

setprompt
