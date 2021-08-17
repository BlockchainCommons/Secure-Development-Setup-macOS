#!/bin/bash

##  Install additional tools for secure development on a Mac.
#
#   Usage: ./additional-setup.sh
#   You may need to make it executable first: chmod +x ./additional-setup.sh

##  SCRIPT DETAILS:
#   
#   This script will:
#   - Ask for your GitHub credentials, install git, and configure it locally
#   - Install GitHub CLI and login with `gh auth login`
#   - Ask if you want a new GPG keypair, and if so:
#       - Download gnupg and pinentry-mac and configure them
#       - Create new keys (interactively)
#       - Create a revocation certificate
#       - Export your public key block to a file (which you need to manually add to your GitHub account settings)
#       - Configure git to use your GPG key and enable commit signing globally
#   - Ask if you want to install GitHub Desktop (helpfull if you don't feel comfortable with the command line)
#   - Ask which IDE/text editor you want installed (VS Code, Typora, or Atom)
#   - Clean things up with `brew cleanup` and refresh with `source ~/.zshrc`

##  TODO:
#   - [ x ] Finish first draft
#   - [ x ] Test first working solution
#   - [ ] Refactor script (https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/)
#   - [ ] Test refactored, final script

##  Part of the code in this script came from or was adapted from:
#
#  * https://github.com/MikeMcQuaid/strap/blob/master/bin/strap.sh
#  * https://github.com/BlockchainCommons/Secure-Development-Setup-macOS/blob/master/initial-macos-developer-setup.sh

# Exit script if any subsequent command fails
set -e

[[ "$1" = "--debug" || -o xtrace ]] && SCRIPT_DEBUG="1"
SCRIPT_SUCCESS=""

# OSX-only stuff. Abort if not OSX.
if [[ "$(uname -s)" != "Darwin" ]]; then
  printf "This script is only for OSX!"
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

# Do not run script as root
[ "$USER" = "root" ] && abort "Run this script as yourself, not root."
groups | grep $Q -E "\b(admin)\b" || abort "Add $USER to the admin group."

# Prevent sleeping during script execution, as long as the machine is on AC power
caffeinate -s -w $$ &

# Ask for git credentials
log "**************************"
log "Make sure you have already created your GitHub account online and verified your email!"
logn "What's your GitHub username? "
read GITHUB_NAME
logn "What's your GitHub account email? "
read GITHUB_EMAIL

# Install and setup Git
log "**************************"
log "Downloading and installing Git"
brew install git
logk
log "Configuring Git"
git config --global user.name "$GITHUB_NAME"
git config --global user.email $GITHUB_EMAIL

# Squelch git 2.x warning message when pushing
if ! git config push.default >/dev/null; then
    git config --global push.default simple
fi
logk

# Install and setup gh
log "**************************"
log "Downloading and installing GitHub CLI"
brew install gh
logk
log "**************************"
logn "FOLLOW THE STEPS BELOW TO CONFIGURE GITHUB CLI:"
log "This will be interactive. Here's what you need to select and/or type through the configuration process:"
log "1. Select GitHub.com if you're setting up a personal account."
log "2. Select your preferred authentication method. Selecting SSH will help you create SSH keys for usage with GitHub. You can then select 'upload your SSH public key to your GitHub account.'"
log "3. Select 'Paste an authentication token.' You will need to head over to your tokens section on GitHub at: https://github.com/settings/tokens "
log "3a. Click 'Generate new token' and give it a descriptive name, for instance 'github cli' "
log "3b. Allow the following 3 permissions by checking their individual boxes: repo, read:org, admin:public_key "
log "3c. Hit create and COPY THE TOKEN! You will need to paste it into the terminal when prompted for. "
gh auth login
logk

log "**************************"
logn "Do you wish to have new GPG keys created for you and configured for usage with Git? y / n: "
read WANTS_GPG

if [[ $WANTS_GPG == "y" ]]; then
    # Install and setup GPG with GitHub
        log "**************************"
        log "Downloading and installing GPG and pinentry-mac."
        brew install gnupg pinentry-mac
        
        # Configure pinentry-mac
        echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
        echo 'export GPG_TTY=$(tty)' >> ~/.zshrc
        
        # Tell GnuPG to always use the longer, more secure 16-character key IDs
        echo "keyid-format long" >> ~/.gnupg/gpg.conf

        logk
        
        log "**************************"
        logn "FOLLOW THE STEPS BELOW TO CREATE & CONFIGURE GPG:"
        log "This will be interactive. You can press 'return' / 'enter' to accept the defaults on the first two steps."
        log "On the third step, select make the key expire in one year by typing 1y"
        log "When asked your email address, provide the one you use with GitHub!"
        log "For your passphrase, grab a dice and refer to: https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt "
        log "Rolling the dice 5 times will give you one word -- you need 6 words so do that 6 times!"
        log "Type in your new passphrase afterwards and make sure you don't forget it! Create a written backup on a secure location if needed!"
        gpg --full-generate-key

        logk

        # Grab KEY_ID for later use
        KEY_ID=$(gpg --list-secret-keys | grep sec | awk '{print substr ($0, 15, 16)}')

        log "**************************"
        logn "Creating a revocation certificate"
        if [[ $(cd; ls | grep gnupg) == "" ]]; then # create directory
            mkdir ~/gnupg; mkdir ~/gnupg/revocable
        fi
        gpg --output ~/gnupg/revocable/revoke.asc --gen-revoke $KEY_ID
        logk

        log "**************************"
        logn "Exporting your public key block to ~/public-key.txt "
        gpg --armor --export $KEY_ID > ~/public-key.txt
        logk
        log "IMPORTANT: Add the contents of ~/public-key.txt to your GitHub account > Settings > SSH and GPG keys > New GPG key\n"

        log "**************************"
        logn "Telling git about your signing key locally"
        git config --global user.signingkey $KEY_ID
        logk

        log "**************************"
        logn "Set commit signing in all repos by default"
        git config --global commit.gpgsign true
        logk

        log "**************************"
        log "WARNING:"
        log "REMEMBER TO ADD YOUR PUBLIC KEY BLOCK TO YOUR GITHUB ACCOUNT BEFORE SIGNING COMMITS!"
        log "Add the contents of ~/public-key.txt to your GPG keys in your GitHub account configurations"
    fi
fi

# Ask if user wants GitHub Desktop installed
log "**************************"
logn "Do you wish to install GitHub Desktop? (an option if you don't like the command line)  y / n: "
read WANTS_GITHUB_DESKTOP

if [[ $WANTS_GITHUB_DESKTOP == "y" ]]; then
    # Install GitHub Desktop
    log "**************************"
    logn "Installing GitHub Desktop"
    brew install github
    log "Nice! You now have GitHub Desktop installed. Now, go ahead and open it to make sure your email address there, under Preferences > Account, is the same as your GitHub email account!"
    log "If the email addresses match, congrats! You can now contribute to open source with signed commits using only GitHub Desktop."
    logk
fi

# Ask which editor the user wants installed
log "**************************"
logn "Which text editor would you like installed?\n
        1. VS Code -- great for code, text, and markdown\n
        2. Typora -- great for markdown\n
        3. Atom -- in-between vs code and typora\n
        -------------------------------------------\n
        [ Type 1, 2 or 3 ]: "
read TEXT_EDITOR

if [[ $TEXT_EDITOR == "1" ]]; then
    log "**************************"
    log "Installing VS Code"
    brew install visual-studio-code
    logk
fi

if [[ $TEXT_EDITOR == "2" ]]; then
    log "**************************"
    log "Installing Typora"
    brew install typora
    echo 'alias typora="open -a typora"' >> ~/.zshrc
    logk
fi

if [[ $TEXT_EDITOR == "3" ]]; then
    log "**************************"
    log "Installing Atom"
    brew install atom
fi

log "**************************"
log "Cleaning up..."
brew cleanup
source ~/.zshrc

SCRIPT_SUCCESS="1"
log "Enjoy your new development machine!"

exit
