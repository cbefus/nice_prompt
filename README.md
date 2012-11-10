
NICE PROMPT
===========

  _   _ _           ______                          _\n
 | \ | (_)          | ___ \                        | |
 |  \| |_  ___ ___  | |_/ / __ ___  _ __ ___  _ __ | |_
 | . ` | |/ __/ _ \ |  __/ '__/ _ \| '_ ` _ \| '_ \| __|
 | |\  | | (_|  __/ | |  | | | (_) | | | | | | |_) | |_
 \_| \_/_|\___\___| \_|  |_|  \___/|_| |_| |_| .__/ \__|
                                             | |
 By Chad R. Befus                            |_|
 ================

A simple to use, fully functional, (includes date, time, user, host, cwd, git status, and virtual env) .bash_profile for your bash prompt.

This prompt is just my attempt at keeping a nice bash prompt.  You are free to use, change, comment on, learn from, explain my mistakes using, and really do as you wish with this script.

Defining Terms
==============

Element - An unchanged prompt item, like date, time, user, etc.
Prompt Part - A fully customized and ready to use prompt item - like the date, colored purple and in bold text.
Color - The color, either foreground or background, used, like red, black, etc.
Foreground - The text of the element itself
Background - The highlighting or background color of the element
Attribute - text effects like bold, underline, blink, ect.


Changing Colors / Attributes
============================

Find the Element you wish to change the color or attribute of in the code.  For example, if we wanted to change the color of the date to bold purple on light black we would find the line:

    date_color=$(_set_color "none" "black" "light" "none" "normal")

Change the colors and attributes to say:

    date_color=$(_set_color "bold" "purple" "normal", "black", "light")

Note the order of input is:
    _set_color: the function call to the ascii_code generator
    "bold": the attribute we want to apply to the text
    "purple": the text / foreground color
    "normal": since we dont want the text to be light purple
    "black": the highlight or background color
    "light": because we want the black to be light

Coloring any and all elements works with this same pattern.


Changing Prompt Part Order / Separators / etc.
==============================================

Find the function _prompt_command and look for the PS1= line:

    PS1=$date_part' at '$time_part' '$username_part'@'$hostname_part' in '$cwd_part' '$NEW_LINE' ['$git_part'] '$virtualenv_part' '$separator_part' '$input_part

This is just a giant string, rearrange the parts as you wish, add parts, remove parts, add syntax, ect.


Enjoy.
Chad R Befus.
