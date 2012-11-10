
# These are all the options available to your bash prompt parts.
# Do not mess with the order of this array asi it is key to generating the
# ascii codes below.
attribute_array=("none" "bold" "underscore" "blink" "reverse" "concealed")
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

# These are all of the color options available for your bash prompt parts.
# This includes foreground and background. Do not mess with the order of this
# array as it is key to generating the ascii codes below.
color_array=("black" "red" "green" "yellow" "blue" "purple" "cyan" "white")
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

foreground_color_ascii_code_start="30"
background_color_ascii_code_start="40"
light_color_ascii_modifier="60"
control_start="\["
control_end="\]"
ascii_escape_prefix="\033"
color_postfix="m"
function _set_color() {
    attribute_string=$1
    foreground_string=$2
    foreground_light_string=$3
    background_string=$4
    background_light_string=$5
    ascii_attribute_code=$(_get_attribute_array_index $attribute_string $attribute_array)

    ascii_foreground_code=$(_get_color_array_index $foreground_string $color_array)
    ascii_foreground_code=$((ascii_foreground_code+foreground_color_ascii_code_start))
    if [ $foreground_light_string == "light" ]
    then
        ascii_foreground_code=$((ascii_foreground_code+light_color_ascii_modifier))
    fi
    ascii_foreground_code=';'$ascii_foreground_code

    if [ $background_string == "none" ]
    then
        ascii_background_code=""
    else
        ascii_background_code=$(_get_color_array_index $background_string $color_array)
        ascii_background_code=$((ascii_background_code+background_color_ascii_code_start))
        if [ $background_light_string == "light" ]
        then
            ascii_background_code=$((ascii_background_code+light_color_ascii_modifier))
        fi
        ascii_background_code=';'$ascii_background_code
    fi

    ascii_prefix=$control_start$ascii_escape_prefix
    ascii_sequence='['$ascii_attribute_code$ascii_foreground_code$ascii_background_code
    ascii_postfix=$color_postfix$control_end
    echo $ascii_prefix$ascii_sequence$ascii_postfix
    return
}

# Reset
color_reset='\[\033[0;0m\]'

# foo=$(_set_color "none" "red" "normal" "black" "normal")
# echo $foo"bar"$color_reset

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

function _virtualenv_prompt() {
    if [[ $VIRTUAL_ENV != "" ]]
    then
        echo $virtualenv_color"(${VIRTUAL_ENV##*/})"
    else
        echo ""
    fi
}

# some usefull constants
back_slash="\\"
new_line="\n"

function _prompt_command() {
    git_part=$(_git_prompt)
    virtualenv_part=$(_virtualenv_prompt)
    PS1=$date_part' at '$time_part' '$username_part'@'$hostname_part' in '$cwd_part' '$new_line' ['$git_part'] '$virtualenv_part' '$separator_part' '$input_part
}

PROMPT_COMMAND=_prompt_command

