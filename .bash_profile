#  _   _ _           ______                          _
# | \ | (_)          | ___ \                        | |
# |  \| |_  ___ ___  | |_/ / __ ___  _ __ ___  _ __ | |_
# | . ` | |/ __/ _ \ |  __/ '__/ _ \| '_ ` _ \| '_ \| __|
# | |\  | | (_|  __/ | |  | | | (_) | | | | | | |_) | |_
# \_| \_/_|\___\___| \_|  |_|  \___/|_| |_| |_| .__/ \__|
#                                             | |
# By Chad R. Befus                            |_|


# These are all the options available to your bash prompt parts.
# Do not mess with the order of this array as it is key to generating the
# ascii codes below.  Note: though these give the correct ascii command
# codes, some options, like blink, will not have any effect on parts of
# a bash prompt.
attribute_array=("none" "bold" "underscore" "blink" "reverse" "concealed")

# These are all of the color options available for your bash prompt parts.
# This includes foreground and background. Do not mess with the order of this
# array as it is key to generating the ascii codes below.
color_array=("black" "red" "green" "yellow" "blue" "purple" "cyan" "white")


# Function: _get_attribute_array_index
# @parameter: find_string <string> - the name of the attribute from the array
# @echos: <int> - the array index of the string
# @example usage:
#       foo=$(_get_attribute_array_index "bold")
#       echo $foo # echos 1
# TODO: Make this function take an array second parameter and work for both
#       attributes and colors.
function _get_attribute_array_index() {
    find_string=$1
    for array_index in ${!attribute_array[*]}
    do
        array_value=${attribute_array[$array_index]}
        if [ "$array_value" == "$find_string" ]
        then
            echo "$array_index"
            return
        fi
    done
    echo "0" # default to first entry
    return
}

# Function: _get_color_array_index
# @parameter: find_string <string> - the name of the color from the array
# @echos: <int> - the array index of the string
# @example usage:
#       foo=$(_get_color_array_index "red")
#       echo $foo # echos 1
# TODO: Make this function take an array second parameter and work for both
#       attributes and colors.
function _get_color_array_index() {
    find_string=$1
    for array_index in ${!color_array[*]}
    do
        array_value=${color_array[$array_index]}
        if [ "$array_value" == "$find_string" ]
        then
            echo "$array_index"
            return
        fi
    done
    echo "0" # default to first entry
    return
}

FOREGROUND_COLOR_ASCII_CODE_START="30"
BACKGROUND_COLOR_ASCII_CODE_START="40"
LIGHT_COLOR_ASCII_MODIFIER="60"
CONTROL_START="\["
CONTROL_END="\]"
ASCII_ESCAPE_PREFIX="\033"
COLOR_POSTFIX="m"

# Function: _set_color()
# @parameter: attribute_string <string> - the name of the attribute from the array or "none"
# @parameter: foreground_string <string> - the foreground color from the array
# @parameter: foreground_light_string <string> - "light" or "normal"
# @parameter: background_string <string> - "the background color from the array"
# @parameter: background_light_string <string> - "light" or "normal"
# @echos: <string> - the ascii code for the prompt color
# @example usage:
#       foo=$(_set_color "bold" "black" "light" "red" "normal")
#       echo $foo # echos \[\033[1;90;41m\]
function _set_color() {
    attribute_string=$1
    foreground_string=$2
    foreground_light_string=$3
    background_string=$4
    background_light_string=$5
    ascii_attribute_code=$(_get_attribute_array_index $attribute_string)

    ascii_foreground_code=$(_get_color_array_index $foreground_string)
    ascii_foreground_code=$((ascii_foreground_code+FOREGROUND_COLOR_ASCII_CODE_START))
    if [ $foreground_light_string == "light" ]
    then
        ascii_foreground_code=$((ascii_foreground_code+LIGHT_COLOR_ASCII_MODIFIER))
    fi
    ascii_foreground_code=';'$ascii_foreground_code

    if [ $background_string == "none" ]
    then
        ascii_background_code=""
    else
        ascii_background_code=$(_get_color_array_index $background_string $color_array)
        ascii_background_code=$((ascii_background_code+BACKGROUND_COLOR_ASCII_CODE_START))
        if [ $background_light_string == "light" ]
        then
            ascii_background_code=$((ascii_background_code+LIGHT_COLOR_ASCII_MODIFIER))
        fi
        ascii_background_code=';'$ascii_background_code
    fi

    ascii_prefix=$CONTROL_START$ASCII_ESCAPE_PREFIX
    ascii_sequence='['$ascii_attribute_code$ascii_foreground_code$ascii_background_code
    ascii_postfix=$COLOR_POSTFIX$CONTROL_END
    echo $ascii_prefix$ascii_sequence$ascii_postfix
    return
}

# Reset
color_reset='\[\033[0;0m\]'

##############################################################################
# PROMPT ELEMENTS
##############################################################################

# Some elements you might want in your prompt
# date
date_color=$(_set_color "none" "black" "light" "none" "normal")
date_part=$date_color"\d"$color_reset

# time
time_color=$(_set_color "blink" "white" "normal" "none" "normal")
time_12h_long="\T"
time_12h_short="\@"
time_24h_long="\t"
time_24h_short="\A"
time_part=$time_color$time_12h_short$color_reset

# CWD
cwd_color=$(_set_color "bold" "green" "normal" "none" "normal")
current_working_path_short="\w"
current_working_path_full="\W"
cwd_part=$cwd_color$current_working_path_short$color_reset

# hostname
hostname_color=$(_set_color "none" "cyan" "normal" "none" "normal")
hostname_short="\h"
hostname_full="\H"
hostname_part=$hostname_color$hostname_short$color_reset

# username
username_color=$(_set_color "none" "purple" "normal" "none" "normal")
username_part=$username_color"\u"$color_reset

# separator
separator_color=$(_set_color "none" "white" "normal" "none" "normal")
separator_part=$separator_color"$"$color_reset

# user input
input_color=$(_set_color "none" "white" "normal" "none" "normal")
input_part=$input_color

#git colors
git_norepo_color=$(_set_color "none" "black" "normal" "blue" "normal")
git_clean_color=$(_set_color "none" "black" "normal" "green" "normal")
git_changed_color=$(_set_color "none" "black" "normal" "red" "normal")
git_untracked_color=$(_set_color "none" "black" "normal" "yellow" "normal")

# Function: _git_prompt
# echos: The git branch name (or "No Repo") with appropriate colors
function _git_prompt() {
    local git_status="`git status -unormal 2>&1`"
    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]
    then
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]
        then
            branch=${BASH_REMATCH[1]}
        else
            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null || echo HEAD`)"
        fi

        if [[ "$git_status" =~ nothing\ to\ commit ]]
        then
            echo -n $git_clean_color$branch$color_reset
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]
        then
            echo -n $git_untracked_color$branch$color_reset
        else
            echo -n $git_changed_color$branch$color_reset
        fi
    else
        echo -n $git_norepo_color"No Repo"$color_reset
    fi
}

# virtual environment colors
virtualenv_color=$(_set_color "bold" "red" "normal" "none" "normal")

# Function: _virtualenv_prompt
# Precondition: $VIRTUAL_ENV must be set
# Echos: The virtual environment name with appropriate coloring or empty
function _virtualenv_prompt() {
    if [[ $VIRTUAL_ENV != "" ]]
    then
        echo $virtualenv_color"(${VIRTUAL_ENV##*/})"
    else
        echo ""
    fi
}

# some usefull constants
BACK_SLASH="\\"
NEW_LINE="\n"

##############################################################################
# THE PROMPT
##############################################################################

# Function: _prompt_command
# Echos: The combination of prompt parts chosen in their respective colors in
#       the order and setup (aka with the syntax) defined in this function.
function _prompt_command() {
    git_part=$(_git_prompt)
    virtualenv_part=$(_virtualenv_prompt)
    PS1=$date_part' at '$time_part' '$username_part'@'$hostname_part' in '$cwd_part' '$NEW_LINE' ['$git_part'] '$virtualenv_part' '$separator_part' '$input_part
}

PROMPT_COMMAND=_prompt_command

