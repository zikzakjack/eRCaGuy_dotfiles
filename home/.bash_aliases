# This file is part of eRCaGuy_dotfiles: https://github.com/ElectricRCAircraftGuy/eRCaGuy_dotfiles

# INSTALLATION & USAGE INSTRUCTIONS:
# See the "eRCaGuy_dotfiles/home/README.md" file, with full instructions, here:
# https://github.com/ElectricRCAircraftGuy/eRCaGuy_dotfiles/tree/master/home

# Make a symlink to this file in your home (~) dir:
#       cd path/to/eRCaGuy_dotfiles/home
#       ln -si "${PWD}/.bash_aliases" ~/.bash_aliases

# Note: to remind yourself what the definition is for any given alias, just run
# `alias some_alias_name` at the terminal.

# ==================================================================================================
# 1. GENERAL (PUBLICLY SHARED) Bash Setup, Variables, Aliases, & Functions
# ==================================================================================================

# Edit Prompt String 1 (PS1) variable to show 1) the shell level and 2) the currently-checked-out
# git branch whenever you are inside any directory containing a local git repository.
# See: [my ans] https://stackoverflow.com/questions/4511407/how-do-i-know-if-im-running-a-nested-shell/57665918#57665918
gs_git_show_branch() {
    GIT_BRANCH="$(git symbolic-ref -q --short HEAD 2>/dev/null)"
    if [ -n "$GIT_BRANCH" ]; then
        echo "$GIT_BRANCH"
    fi
}
#
# OLD:
# - shows shell level, git branch (if in a dir with one), and `hostname present_dir $ ` only,
#   rather than username too
# - has no color
# PS1="\e[7m\$(gs_git_show_branch)\e[m\n\h \w $ "
# PS1='\$SHLVL'":$SHLVL $PS1"
#
# NEW:
# - shows shell level, git branch (if in a dir with one), and `username@hostname:present_dir$ `
# - ie: it simply adds the shell level and git branch on a line above the
#   default-Ubuntu-18-installation prompt!
# - has color, like a default Ubuntu 18 installation does too!
#
PS1="\e[7m\$(gs_git_show_branch)\e[m\n$PS1" # comment out to NOT show git branch!
PS1='\$SHLVL'":$SHLVL $PS1"                 # comment out to NOT show shell level!

# Find a file built by Bazel and therefor sitting in the "build/bin" dir.
alias gs_find_bazel_build_file='find -L build/bin | grep'
# note: the below could also be done with `gs_find_bazel_build_file -i somefilename`
alias gs_find_bazel_build_file_i='find -L build/bin | grep -i'

# Put computer to sleep (ie: suspend it).
# See: https://askubuntu.com/questions/1792/how-can-i-suspend-hibernate-from-command-line/1795#1795
alias gs_suspend='systemctl suspend'

############ TODO: fix this up!
# 1. make it stand-alone
# 2. make it work as `git branch_hash_bak [optional message]`
#   - let the optional message just be the remainder of the arguments, so it doesn't require a quote
#   - however, force it to not contain spaces, so replace spaces with underscores
#   - add the optional message into the filename itself at the end
############
# GS: git branch backups: useful to back up git branch hashes before deleting branches, so you can
# always have their hashes to go back to to checkout rather than having to dig through your `git reflog` forever.
# - Note that this currently requires that the GIT_BRANCH_HASH_BAK_DIR directory already exists.
# - TODO: fail more gracefully: make it check to see if this dir exists & prompt the user for permission to
#   auto-create it with `mkdir -p ${GIT_BRANCH_HASH_BAK_DIR}` if it does not.
#
# Syntax: `gs_git_branch_hash_bak [dir]` = back up to a backup file in directory "dir" if a dir is passed in
GIT_BRANCH_HASH_BAK_DEFAULT_DIR="./git_branch_hash_backups"
gs_git_branch_hash_bak () {
    GIT_BRANCH_HASH_BAK_DIR="$GIT_BRANCH_HASH_BAK_DEFAULT_DIR"
    EXIT_SUCCESS=0
    EXIT_ERROR=1

    # Help menu
    if [ "$1" == "-h" ] || [ "$1" == "-?" ]; then
        echo "This is a bash function in \"~/.bash_aliases\" which backs up git branch"
        echo "names & short hashes to your local \"${GIT_BRANCH_HASH_BAK_DEFAULT_DIR}\" (or other"
        echo "specified) dir."
        echo ""
        echo "Usage: $0 [dir]"
        echo "    Back up branch names and hashes to a backup file in directory \"dir\"."
        return $EXIT_SUCCESS
    fi

    if [ -n "$1" ]; then
        # If an arg is passed in, then use it instead of the default directory!
        GIT_BRANCH_HASH_BAK_DIR="$1"
    fi

    DATE=`date +%Y%m%d-%H%Mhrs-%Ssec`
    BRANCH="$(gs_git_show_branch)"
    DIR=$(pwd)
    REPO=$(basename "$DIR") # repository name
    # Replace any spaces in the repository name with underscores
    # See: https://stackoverflow.com/questions/19661267/replace-spaces-with-underscores-via-bash/19661428#19661428
    REPO="${REPO// /_}"
    FILE="${GIT_BRANCH_HASH_BAK_DIR}/${REPO}_git_branch_bak--${DATE}.txt"

    echo "Backing up 'git branch -vv' info to \"$FILE\"."
    echo -e "date = \"$DATE\"" > $FILE
    echo -e "repo (folder) name = \"$REPO\"" >> $FILE
    echo -e "pwd = \"$DIR\"" >> $FILE
    echo -e "current branch name = \"$BRANCH\"" >> $FILE
    echo -e "\n=== \`git branch -vv\` ===\n" >> $FILE
    git branch -vv >> $FILE
    echo "Done!"
}
# Alias to do the git hash backups in a directory one higher so you don't have to add this backup
# dir to this git project's .gitignore file
alias gs_git_branch_hash_bak_up1="gs_git_branch_hash_bak \"../git_branch_hash_backups\""

# ssh into another computer. Override this ssh command by re-defining it in
# "~/.bash_aliases_private"! Make the username, domain_name, & options what they should be for you.
# Notes:
# 1) enable X11 window forwarding with `-X`; see here:
#    https://unix.stackexchange.com/questions/12755/how-to-forward-x-over-ssh-to-run-graphics-applications-remotely/12772#12772
# 2) keep the connection alive with `-o "ServerAliveInterval 60"`; see here:
#    https://superuser.com/questions/699676/how-to-prevent-ssh-from-disconnecting-if-its-been-idle-for-a-while/699680#699680
alias gs_ssh="ssh -X -o \"ServerAliveInterval 60\" username@domain_name"

# Mount a remote file system securely over ssh, using sshfs (SSH File System).
# See my own answer here!:
# https://askubuntu.com/questions/791002/how-to-prevent-sshfs-mount-freeze-after-changing-connection-after-suspend/942820#942820
alias gs_sshfs="sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 \
username@server_hostname:/path/on/server/to/mount ~/mnt/my_server"
alias gs_sshfs_umount="sudo umount ~/mnt/my_server"

# #-----------------------------------------------------------------------------------------------------------------------
# # TERMINAL TABS & TITLE (START)

# # Back up original PS1 Prompt 1 string when ~/.bashrc is first sourced upon bash opening; this must be placed
# # AFTER all other modifications have already occured to the `PS1` Prompt String 1 variable
# if [[ -z "$PS1_BAK" ]]; then # If length of this str is zero (see `man test`)
#     PS1_BAK=$PS1
# fi

# # Set the title string at the top of your current terminal window or terminal window tab.
# # See: https://unix.stackexchange.com/questions/177572/how-to-rename-terminal-tab-title-in-gnome-terminal/566383#566383
# # and: https://askubuntu.com/questions/315408/open-terminal-with-multiple-tabs-and-execute-application/1026563#1026563
# # - Example usage:
# #   - A) Static title strings (title remains fixed):
# #     - `set-title my tab 1` OR `set-title "my tab 1"`
# #     - `set-title $PWD` OR `set-title "$PWD"`
# #   - B) Dynamic title strings (title updates each time you enter any terminal command): you may use function calls or
# #     variables within your title string and have them *dynamically* updated each time you enter a new command.
# #     Simply enter a command or access a global variable inside your title string. **Be sure to use _single quotes_
# #     around the title string for this to work!**:
# #     - `set-title '$PWD'` - this updates the title to the Present Working Directory every time you `cd` to a new
# #        directory!
# #     - `set-title '$(date "+%m/%d/%Y - %k:%M:%S")'` - this updates the title to the new date and time every time
# #        it changes *and* you enter a new terminal command! The format looks like this: `02/06/2020 - 23:32:58`
# gs_set-title() {
#     # Set the PS1 title escape sequence; see "Customizing the terminal window title" here:
#     # https://wiki.archlinux.org/index.php/Bash/Prompt_customization#Customizing_the_terminal_window_title
#     TITLE="\[\e]2;$@\a\]"
#     PS1=${PS1_BAK}${TITLE}
# }
# alias gs_set-title_echo='echo -e "This is a bash function in \"~/.bashrc\" which sets the title of your \
# currently-opened terminal tab'

# # Set the title to a user-specified value if and only if TITLE_DEFAULT has been previously set and
# # exported by the user. This can be accomplished as follows:
# #   export TITLE_DEFAULT="my title"
# #   . ~/.bashrc
# # Note that sourcing the ~/.bashrc file is done automatically by bash each time you open a new bash
# # terminal, so long as it is an interactive (use `bash -i` if calling bash directly) type terminal
# if [[ -n "$TITLE_DEFAULT" ]]; then # If length of this is NONzero (see `man test`)
#     gs_set-title "$TITLE_DEFAULT"
# fi

# # ----------------------------------------------
# # Configure default tabs to open if desired
# # - UPDATE TITLES AND CMDS TO SUIT YOUR NEEDS!
# # - See: https://askubuntu.com/questions/315408/open-terminal-with-multiple-tabs-and-execute-application/1026563#1026563
# # ----------------------------------------------

# # Tab titles
# DEFAULT_TABS_TITLE1="git"
# DEFAULT_TABS_TITLE2="bazel"
# DEFAULT_TABS_TITLE3="Python"
# DEFAULT_TABS_TITLE4="ssh1"
# DEFAULT_TABS_TITLE5="ssh2"
# DEFAULT_TABS_TITLE6="ssh3"
# DEFAULT_TABS_TITLE7="other"

# # Tab commands
# # Note: use quotes like this if there are spaces in the path: `DEFAULT_TABS_CMD3="cd '$HOME/temp/test folder'"`
# DEFAULT_TABS_CMD1="cd '$HOME/GS/dev'"
# DEFAULT_TABS_CMD2="cd '$HOME/GS/dev'"
# DEFAULT_TABS_CMD3="cd '$HOME/GS/dev'"
# DEFAULT_TABS_CMD4="cd '$HOME/GS/dev'"
# DEFAULT_TABS_CMD5="cd '$HOME/GS/dev'"
# DEFAULT_TABS_CMD6="cd '$HOME/GS/dev'"
# DEFAULT_TABS_CMD7="cd '$HOME/GS/dev'"

# # Call this function to open up the following tabs, calling the desired command in each tab and setting
# # the title of each tab as desired. This is really helpful to get your programming environment set up
# # for software development work, for instance.
# gs_open_default_tabs() {
#     # Ex of how to do this in the `terminator` terminal
#     # terminator --new-tab --command='ls; cd dev; ls; exec bash;'

#     terminator --new-tab --command="export TITLE_DEFAULT='$DEFAULT_TABS_TITLE1'; $DEFAULT_TABS_CMD1; exec bash;"
#     terminator --new-tab --command="export TITLE_DEFAULT='$DEFAULT_TABS_TITLE2'; $DEFAULT_TABS_CMD2; exec bash;"
#     terminator --new-tab --command="export TITLE_DEFAULT='$DEFAULT_TABS_TITLE3'; $DEFAULT_TABS_CMD3; exec bash;"
#     terminator --new-tab --command="export TITLE_DEFAULT='$DEFAULT_TABS_TITLE4'; $DEFAULT_TABS_CMD4; exec bash;"
#     terminator --new-tab --command="export TITLE_DEFAULT='$DEFAULT_TABS_TITLE5'; $DEFAULT_TABS_CMD5; exec bash;"
#     terminator --new-tab --command="export TITLE_DEFAULT='$DEFAULT_TABS_TITLE6'; $DEFAULT_TABS_CMD6; exec bash;"
#     terminator --new-tab --command="export TITLE_DEFAULT='$DEFAULT_TABS_TITLE7'; $DEFAULT_TABS_CMD7; exec bash;"

#     # gnome-terminal --tab -- bash -ic "export TITLE_DEFAULT='$DEFAULT_TABS_TITLE1'; $DEFAULT_TABS_CMD1; exec bash;"
#     # gnome-terminal --tab -- bash -ic "export TITLE_DEFAULT='$DEFAULT_TABS_TITLE2'; $DEFAULT_TABS_CMD2; exec bash;"
#     # gnome-terminal --tab -- bash -ic "export TITLE_DEFAULT='$DEFAULT_TABS_TITLE3'; $DEFAULT_TABS_CMD3; exec bash;"
#     # gnome-terminal --tab -- bash -ic "export TITLE_DEFAULT='$DEFAULT_TABS_TITLE4'; $DEFAULT_TABS_CMD4; exec bash;"
#     # gnome-terminal --tab -- bash -ic "export TITLE_DEFAULT='$DEFAULT_TABS_TITLE5'; $DEFAULT_TABS_CMD5; exec bash;"
#     # gnome-terminal --tab -- bash -ic "export TITLE_DEFAULT='$DEFAULT_TABS_TITLE6'; $DEFAULT_TABS_CMD6; exec bash;"
#     # gnome-terminal --tab -- bash -ic "export TITLE_DEFAULT='$DEFAULT_TABS_TITLE7'; $DEFAULT_TABS_CMD7; exec bash;"
# }

# # # This chunk of code allows one to essentially call `open_default_tabs` from another script to open up all
# # # default tabs in a brand new terminal window simply by entering these lines into your script:
# # #   export OPEN_DEFAULT_TABS=true
# # #   gnome-terminal          # this also sources ~/.bashrc (this script)
# # #   OPEN_DEFAULT_TABS=      # set this variable back to an empty string so it's no longer in force
# # #   unset OPEN_DEFAULT_TABS # unexport it
# # # See "eRCaGuy_dotfiles/useful_scripts/open_programming_tools.sh" for a full example & more detailed comments.
# # if [[ -n "$OPEN_DEFAULT_TABS" ]]; then # If length of this is NONzero (see `man test`)
# #     # Reset to an empty string so this only happens ONCE since ~/.bashrc is about to be sourced recursively
# #     OPEN_DEFAULT_TABS=
# #     gs_open_default_tabs
# #     # close the calling process so only the "default tabs" are left open while the initial `gnome-terminal` tab
# #     # that opened all the other tabs is now closed
# #     exit 0
# # fi

# # TERMINAL TABS & TITLE (END)
# #-----------------------------------------------------------------------------------------------------------------------

# Play sound; very useful to add to the end of a long cmd you want to be notified of when it completes!
# Ex: `long_cmd; gs_sound_bell` will play a bell sound when `long_cmd` completes!
alias gs_sound_bell="echo -e \"\a\""

# Even better, have a pop-up notification too!
# Ex: `long_cmd; gs_alert` will play the sound above *and* pop up a notification when complete!
# See more details & a screenshot of the popup on my answer here:
#   https://askubuntu.com/questions/277215/how-to-make-a-sound-once-a-process-is-complete/1213564#1213564
# For other popup window options, see my other answer here:
#   https://superuser.com/questions/31917/is-there-a-way-to-show-notification-from-bash-script-in-ubuntu/1310142#1310142
alias gs_alert="gs_sound_bell; alert \"task complete\""

# More sounds:
# From: https://askubuntu.com/questions/277215/how-to-make-a-sound-once-a-process-is-complete/604116#604116
sound() {
  # plays sounds in sequence and waits for them to finish
  for s in $@; do
    paplay $s
  done
}
# Run these commands directly from the terminal to play these sounds; ex: `sn1`, `sn2`, `sn3`
# Tick!
sn1() {
  sound /usr/share/sounds/ubuntu/stereo/dialog-information.ogg
}
# Dingggg!
sn2() {
  sound /usr/share/sounds/freedesktop/stereo/complete.oga
}
# Beeebeebeeebeeebeee!
sn3() {
  sound /usr/share/sounds/freedesktop/stereo/suspend-error.oga
}

# Text to speech as a sound: use cmd: `spd-say "some text to read"`
# Ex: `long_cmd; spd-say done` OR `long_cmd; gs_say_done` <=== AMAZING!
# See also: https://askubuntu.com/questions/277215/how-to-make-a-sound-once-a-process-is-complete/587575#587575
alias gs_say_done="spd-say \"Done!\""
alias gs_say_complete="spd-say \"Operation Complete!\""

# Find and replace strings in a file.
# Posted here: https://stackoverflow.com/questions/12144158/how-to-check-if-sed-has-changed-a-file
# Usage: `gs_replace_str "regex_search_pattern" "replacement_string" "file_path"`
# Ex:    `gs_replace_str "myFunc(" "myNewFunc(" "my_file.cpp"`
gs_replace_str() {
    # Help menu
    if [ "$1" == "-h" ] || [ "$1" == "-?" ]; then
        echo "Find and replace strings in a file."
        echo "Usage:   $0 <\"regex_search_pattern\"> <\"replacement_string\"> <\"file_path\">"
        echo "Example: $0 \"myFunc(\" \"myNewFunc(\" \"my_file.cpp\""
        return $EXIT_SUCCESS
    fi

    REGEX_SEARCH="$1"
    REPLACEMENT_STR="$2"
    FILENAME="$3"

    num_lines_matched=$(grep -c -E "$REGEX_SEARCH" "$FILENAME")
    # Also count number of matches, NOT just lines (`grep -c` counts lines), in case there are
    # multiple matches per line; see:
    # https://superuser.com/questions/339522/counting-total-number-of-matches-with-grep-instead-of-just-how-many-lines-match/339523#339523
    num_matches=$(grep -o -E "$REGEX_SEARCH" "$FILENAME" | wc -l)

    echo -e "\n${num_matches} matches found on ${num_lines_matched} lines in file \"${FILENAME}\":"

    if [ "$num_matches" -gt 0 ]; then
        # Now *show these exact matches* with their corresponding line 'n'umbers in the file
        grep -n --color=always -E "$REGEX_SEARCH" "$FILENAME"
        # Now actually *DO the string replacing* on the files 'i'n place using the `sed`
        # 's'tream 'ed'itor!
        sed -i "s|${REGEX_SEARCH}|${REPLACEMENT_STR}|g" "$FILENAME"
    fi
}


# ==================================================================================================
# 2. PERSONAL (PRIVATE) Bash Setup, Variables, Aliases, & Functions
# - Add your personal, custom, or otherwise unshared bash aliases and functions to
#   the "~/.bash_aliases_private" file (recommended), or here below.
# - It is recommended to use the "~/.bash_aliases_private" file.
# - All bash aliases or functions in that file, or below, will override any above if they
#   have the same name.
# ==================================================================================================

# # Import this "~/.bash_aliases_private" file, if it exists.
# if [ -f ~/.bash_aliases_private ]; then
#     . ~/.bash_aliases_private
# fi
