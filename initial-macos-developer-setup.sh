```shell
#!/bin/bash

##  Original file location: 
#   https://gist.github.com/ChristopherA/c06ac0a85da27216ee65603539b999c1

##  Install development dependencies for macOS
#
#   Usage: ./initial-macos-developer-setup.sh [--debug]
#
#   Bash script installing the basic developer macOS command line
#   development tools from Apple for this particular version of macOS,
#   installs the `brew` package manager, and a few essential brew
#   tap sources and settings.
#
#   This script does not install any brew packages or configure your
#   Github credentials, ssh or gpg.

## Copyright
#
#  Unless otherwise noted the contents of this file are
#  Copyright :copyright:2021 by Christopher Allen, and are shared
#  under the [spdx:MIT License](https://spdx.org/licenses/MIT.html)
#  open-source license.

## Support My Open Source & Digital Civil Rights Advocacy Efforts
#
#  If you like these tools, my writing, my advocacy, my point-of-view, I invite
#  you to sponsor me.
#
#  It's a way to plug into an advocacy network that's not focused on the "big guys".
#  I work to represent smaller developers in a vendor-neutral, platform-neutral way,
#  helping us all to work together.
#
#  You can become a monthly patron on my
#  [GitHub Sponsor Page](https://github.com/sponsors/ChristopherA) for as little
#  as $5 a month; and your contributions will be multipled, as GitHub is matching
#  the first $5,000!
#
#  But please don’t think of this as a transaction. It’s an opportunity to advance
#  the open web, digital civil liberties, and human rights together. You get to
#  plug into my various projects, and hopefully will find a way to actively
#  contribute to the digital commons yourself. Let’s collaborate!
#
#  -- Christopher Allen <ChristopherA@LifeWithAlacrity.com\>
#     Github: [@ChristopherA](https://github.com/ChristopherA)
#     Twitter: [@ChristopherA](https://twitter.com/ChristopherA)

# SCRIPT DETAILS:
#
# This script will:
#   * ask for your administrative password
#   * download any recent macOS updates
#   * install the [`brew` Mac](https://brew.sh) Package Manager
#   * tap a few essential sources for brew installation files
#   * check to see if any of these changes need additional Apple updates
#
# If you downloaded this script from gist, you may need to make it executable:
# 
#   chmod +x ./initial-macos-developer-setup.sh
#
# To run the script:
#
#   ./initial-macos-developer-setup.sh
#
# Optionally in debug mode
#
#   ./initial-macos-developer-setup.sh --debug

## TESTED WITH
#  * macOS Big Sur 11.5 on Intel Mac
#  * macOS Monterey 11.0 on Intel Mac


# Inspiration for this code is from many places, but in particular:
#   * https://github.com/MikeMcQuaid/strap/blob/master/bin/strap.sh
#   * https://github.com/chcokr/osx-init/blob/master/install.sh
#   * https://github.com/timsutton/osx-vm-templates/blob/ce8df8a7468faa7c5312444ece1b977c1b2f77a4/scripts/xcode-cli-tools.sh
#   * https://apple.stackexchange.com/questions/219507/best-way-to-check-in-bash-if-command-line-tools-are-installed#comment336847_219708

set -e

[[ "$1" = "--debug" || -o xtrace ]] && SCRIPT_DEBUG="1"
SCRIPT_SUCCESS=""

# OSX-only stuff. Abort if not OSX.
if [ "$(uname -s)" != "Darwin" ]
then
  printf "This script is only for OSX!\n"
  exit 1
fi

sudo_askpass() {
  if [ -n "$SUDO_ASKPASS" ]; then
    sudo --askpass "$@"
  else
    sudo "$@"
  fi
}

cleanup() {
  set +e
  sudo_askpass rm -rf "$CLT_PLACEHOLDER" "$SUDO_ASKPASS" "$SUDO_ASKPASS_DIR"
  sudo --reset-timestamp
  if [ -z "$SCRIPT_SUCCESS" ]; then
    if [ -n "$SCRIPT_STEP" ]; then
      echo "!!! $SCRIPT_STEP FAILED" >&2
    else
      echo "!!! FAILED" >&2
    fi
    if [ -z "$SCRIPT_DEBUG" ]; then
      echo "!!! Run '$0 --debug' for debugging output." >&2
      # echo "!!! If you're stuck: file an issue with debugging output at:" >&2
      echo "!!!   $SCRIPT_ISSUES_URL" >&2
    fi
  fi
}

trap "cleanup" EXIT

if [ -n "$SCRIPT_DEBUG" ]; then
  set -x
else
  SCRIPT_QUIET_FLAG="-q"
  Q="$SCRIPT_QUIET_FLAG"
fi

STDIN_FILE_DESCRIPTOR="0"
[ -t "$STDIN_FILE_DESCRIPTOR" ] && SCRIPT_INTERACTIVE="1"

# We want to always prompt for sudo password at least once rather than doing
# root stuff unexpectedly.
sudo --reset-timestamp

# functions for turning off debug for use when handling the user password
clear_debug() {
  set +x
}

reset_debug() {
  if [ -n "$SCRIPT_DEBUG" ]; then
    set -x
  fi
}

# Initialise (or reinitialise) sudo to save unhelpful prompts later.
sudo_init() {
  if [ -z "$SCRIPT_INTERACTIVE" ]; then
    return
  fi

  local SUDO_PASSWORD SUDO_PASSWORD_SCRIPT

  if ! sudo --validate --non-interactive &>/dev/null; then
    while true; do
      read -rsp "--> Enter your password (for sudo access):" SUDO_PASSWORD
      echo
      if sudo --validate --stdin 2>/dev/null <<<"$SUDO_PASSWORD"; then
        break
      fi

      unset SUDO_PASSWORD
      echo "!!! Wrong password!" >&2
    done

    clear_debug
    SUDO_PASSWORD_SCRIPT="$(cat <<BASH
#!/bin/bash
echo "$SUDO_PASSWORD"
BASH
)"
    unset SUDO_PASSWORD
    SUDO_ASKPASS_DIR="$(mktemp -d)"
    SUDO_ASKPASS="$(mktemp "$SUDO_ASKPASS_DIR"/strap-askpass-XXXXXXXX)"
    chmod 700 "$SUDO_ASKPASS_DIR" "$SUDO_ASKPASS"
    bash -c "cat > '$SUDO_ASKPASS'" <<<"$SUDO_PASSWORD_SCRIPT"
    unset SUDO_PASSWORD_SCRIPT
    reset_debug

    export SUDO_ASKPASS
  fi
}

sudo_refresh() {
  clear_debug
  if [ -n "$SUDO_ASKPASS" ]; then
    sudo --askpass --validate
  else
    sudo_init
  fi
  reset_debug
}

abort() { SCRIPT_STEP="";   echo "!!! $*" >&2; exit 1; }
log()   { SCRIPT_STEP="$*"; sudo_refresh; echo "--> $*"; }
logn()  { SCRIPT_STEP="$*"; sudo_refresh; printf -- "--> %s " "$*"; }
logk()  { SCRIPT_STEP="";   echo "OK"; }
escape() {
  printf '%s' "${1//\'/\'}"
}

[ "$USER" = "root" ] && abort "Run this script as yourself, not root."
groups | grep $Q -E "\b(admin)\b" || abort "Add $USER to the admin group."

# Prevent sleeping during script execution, as long as the machine is on AC power
caffeinate -s -w $$ &

# ## Install xcode command line tools.

# simplier cli install test learned strap uses, but fails in more recent macOS
# if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ] ; then

# alternative https://apple.stackexchange.com/questions/219507/best-way-to-check-in-bash-if-command-line-tools-are-installed#comment336847_219708 test, and also tests install

if      pkgutil --pkg-info com.apple.pkg.CLTools_Executables >/dev/null 2>&1 ; then
#         printf '%s\n' "CHECKING INSTALLATION"
#         count=0
#         pkgutil --files com.apple.pkg.CLTools_Executables |
#         while IFS= read file
#         do
#         test -e  "/${file}"         &&
#         printf '%s\n' "/${file}…OK" ||
#         { printf '%s\n' "/${file}…MISSING"; ((count++)); }
#         done
#         if      (( count > 0 ))
#         then    printf '%s\n' "Command Line Tools are not installed properly"
#                 # Provide instructions to remove and the CommandLineTools directory
#                 # and the package receipt then install instructions
#         else
    log "Command Line Tools are installed."
#         fi
else
  log "The Xcode Command Line Tools are NOT INSTALLED!"
  log "Installing the Xcode Command Line Tools:"
  CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  sudo_askpass touch "$CLT_PLACEHOLDER"

  CLT_PACKAGE=$(softwareupdate -l | \
                grep -B 1 "Command Line Tools" | \
                awk -F"*" '/^ *\*/ {print $2}' | \
                sed -e 's/^ *Label: //' -e 's/^ *//' | \
                sort -V |
                tail -n1)
  sudo_askpass softwareupdate -i "$CLT_PACKAGE"
  sudo_askpass rm -f "$CLT_PLACEHOLDER"
  if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]
  then
    if [ -n "$SCRIPT_INTERACTIVE" ]; then
      echo
      logn "Requesting user install of Xcode Command Line Tools:"
      xcode-select --install
    else
      echo
      abort "Run 'xcode-select --install' to install the Xcode Command Line Tools."
    fi
  fi
  logk
fi

## A working older and simpler brew install, however, may not work with m1 macs.
# ## Install brew if it is not installed, otherwise update it
# if [[ $(command -v brew) == "" ]]
# then
#     log "Installing Hombrew"
#     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
# else
#     log "Updating Homebrew"
#     brew update
# fi

#install homebrew

# This is from strap
# https://github.com/MikeMcQuaid/strap/blob/master/bin/strap.sh

# Check if the Xcode license is agreed to and agree if not.
xcode_license() {
  if /usr/bin/xcrun clang 2>&1 | grep $Q license; then
    if [ -n "$SCRIPT_INTERACTIVE" ]; then
      logn "Asking for Xcode license confirmation:"
      sudo_askpass xcodebuild -license
      logk
    else
      abort "Run 'sudo xcodebuild -license' to agree to the Xcode license."
    fi
  fi
}
xcode_license

# Setup Homebrew directory and permissions.
logn "Installing Homebrew:"
HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
HOMEBREW_REPOSITORY="$(brew --repository 2>/dev/null || true)"
if [ -z "$HOMEBREW_PREFIX" ] || [ -z "$HOMEBREW_REPOSITORY" ]; then
  UNAME_MACHINE="$(/usr/bin/uname -m)"
  if [[ "$UNAME_MACHINE" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
    HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"
  else
    HOMEBREW_PREFIX="/usr/local"
    HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
  fi
fi
[ -d "$HOMEBREW_PREFIX" ] || sudo_askpass mkdir -p "$HOMEBREW_PREFIX"
if [ "$HOMEBREW_PREFIX" = "/usr/local" ]
then
  sudo_askpass chown "root:wheel" "$HOMEBREW_PREFIX" 2>/dev/null || true
fi
(
  cd "$HOMEBREW_PREFIX"
  sudo_askpass mkdir -p               Cellar Frameworks bin etc include lib opt sbin share var
  sudo_askpass chown -R "$USER:admin" Cellar Frameworks bin etc include lib opt sbin share var
)

[ -d "$HOMEBREW_REPOSITORY" ] || sudo_askpass mkdir -p "$HOMEBREW_REPOSITORY"
sudo_askpass chown -R "$USER:admin" "$HOMEBREW_REPOSITORY"

if [ $HOMEBREW_PREFIX != $HOMEBREW_REPOSITORY ]
then
  ln -sf "$HOMEBREW_REPOSITORY/bin/brew" "$HOMEBREW_PREFIX/bin/brew"
fi

# Download Homebrew.
export GIT_DIR="$HOMEBREW_REPOSITORY/.git" GIT_WORK_TREE="$HOMEBREW_REPOSITORY"
git init $Q
git config remote.origin.url "https://github.com/Homebrew/brew"
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch $Q --tags --force
git reset $Q --hard origin/master
unset GIT_DIR GIT_WORK_TREE
logk

# Update Homebrew.
export PATH="$HOMEBREW_PREFIX/bin:$PATH"
log "Updating Homebrew:"
brew update
logk

# Install Homebrew Bundle, Cask and Services tap.
log "Installing Homebrew taps and extensions:"
brew bundle --file=- <<BREWBUNDLE
tap 'homebrew/cask'
tap 'homebrew/core'
tap 'homebrew/services'
BREWBUNDLE
logk

# Check for and install any remaining Apple software updates that might be 
# triggered due to these changes.
logn "Checking for any other Apple software updates:"
if softwareupdate -l 2>&1 | grep $Q "No new software available."; then
  logk
else
  echo
  log "Installing software updates:"
  if [ -z "$SCRIPT_CI" ]; then
    sudo_askpass softwareupdate --install --all
    xcode_license
  else
    echo "Skipping software updates for CI"
  fi
  logk
fi

SCRIPT_SUCCESS="1"
log "Your system has been setup for development!"

exit
```

