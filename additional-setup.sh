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
#   * https://github.com/MikeMcQuaid/strap/blob/master/bin/strap.sh
#   * https://github.com/BlockchainCommons/Secure-Development-Setup-macOS/blob/master/initial-macos-developer-setup.sh

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

# Install Git
if [[ $(command -v git) == "" ]]; then
    log "**************************"
    log "No git installed!"
    log "Installing git..."
    brew install git
    logk
fi

# Setup Git
if [[ $(git config user.name) == "" && $(git config user.email) == "" ]]; then
    log "**************************"
    log "No git credentials configured!"
    logn "What's your GitHub username? "
    read GITHUB_NAME
    logn "What's your GitHub account email? "
    read GITHUB_EMAIL
    log "Configuring Git..."
    git config --global user.name "$GITHUB_NAME"
    git config --global user.email $GITHUB_EMAIL
    logk
fi

# Squelch git 2.x warning message when pushing
if ! git config push.default >/dev/null; then
    git config --global push.default simple
fi

# Install gh
if [[ $(command -v gh) == "" ]]; then
    log "**************************"
    log "No gh installed!"
    log "Installing GitHub CLI (gh)..."
    brew install gh
    logk
fi

# Log into gh
if !(gh auth status --hostname "github.com" > /dev/null 2>&1); then
    log "**************************"
    log "You are not logged into gh!"
    log "Authenticate gh and set SSH as default."
    # Authenticate with the Web
    gh auth login --web
    log "Logged into GitHub."
    logk
fi

# Get the GitHub User Name from GitHub's `gh` cli config files
GH_USER=$(cat <~/.config/gh/hosts.yml | grep -A0 user: | cut -d: -f2 | tr -d ' "')

log "Checking if your git and gh credentials match..."
if [[ $GH_USER == $(git config user.name) ]]; then
    logk
else
    abort "Your credentials on git and gh do not match! Exiting..."
fi

# Check for zshrc file, create if not
if [[ $(ls -a ~/ | grep .zshrc) == "" ]]; then
    touch ~/.zshrc
fi

# Add path used for `brew` formulae
echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.zshrc

# Install GPG and pinentry-mac
if [[ $(command -v gpg) == "" ]]; then
    log "**************************"
    log "No GPG installed!"
    log "Installing GPG and pinentry-mac..."
    # gnupg, gnupg2, gpg, and gpg2 are now one and the same https://formulae.brew.sh/formula/gnupg
    brew install gnupg pinentry-mac
    logk
fi

# Check for existing key on GitHub
GH_PUBLIC_KEY=$(curl https://github.com/$GH_USER.gpg 2>/dev/null)
if [ -z "$GH_PUBLIC_KEY" ]; then
    
    log "**************************"
    log "No GPG keys found on your GitHub account."
    logn "Do you want to create a new GPG keypair? [y / n]: "
    read WANTS_GPG

    if [[ $WANTS_GPG == "y" ]]; then
  
        log "**************************"
        logn "Creating a new GPG keypair..."
        log "Type your name and GitHub email when prompted."
        log "Passphrase - roll a dice 5 times and match it against https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt"
        log "Do that 6 times to have a secure 6-word passphrase."
        sleep 2s # give some time to read the above...
        
        # gpg --full-generate-key
        # Generate key using defaults instead - prompt only for uid and passphrase - will expire in 2y
        # Will also auto-generate a revocation certificate
        gpg --gen-key

        # Grab KEY_ID for later use
        KEY_ID=$(gpg --list-secret-keys | grep sec | awk '{print substr ($0, 15, 16)}')

        logk
    else
        logn "Do you wish to import a private key into ~/.gnupg ? [y / n]: "
        read IMPORTS_PRIVATE_KEY
        if [[ $IMPORTS_PRIVATE_KEY == "y" ]]; then
            logn "Type the private key file full path: "
            read PRIVATE_KEY_PATH

            # Import private key to ~/.gnupg
            log "Importing your private key to ~/.gnupg..."
            gpg --import $PRIVATE_KEY_PATH

            # Grab KEY_ID for later use
            KEY_ID=$(gpg --list-secret-keys | grep sec | awk '{print substr ($0, 15, 16)}')

            # Trust key -- this is from https://unix.stackexchange.com/a/392355
            # Sometimes necessary after import
            log "Trusting your key..."
            expect -c 'spawn gpg --edit-key $KEY_ID trust quit; send "5\ry\r"; expect eof'

            logk
        fi

    fi

else
    log "GPG key found at https://github.com/$GH_USER.gpg"
    # Download key to ~/.gnupg
    log "Saving your public key to ~/public.key and importing it to ~/.gnupg"
    echo $GH_PUBLIC_KEY > ~/public.key
    gpg --import-options import-show --import ~/public.key
    
    # Ask for private key file path
    logn "Do you wish to import a private key into ~/.gnupg ? [y / n]: "
    read IMPORTS_PRIVATE_KEY
    if [[ $IMPORTS_PRIVATE_KEY == "y" ]]; then
        logn "Type the private key file full path: "
        read PRIVATE_KEY_PATH

        # Import private key to ~/.gnupg
        log "Importing your private key to ~/.gnupg..."
        gpg --import $PRIVATE_KEY_PATH

        # Grab KEY_ID for later use
        KEY_ID=$(gpg --list-secret-keys | grep sec | awk '{print substr ($0, 15, 16)}')

        # Trust key -- this is from https://unix.stackexchange.com/a/392355
        # Sometimes necessary after import
        log "Trusting your key..."
        expect -c 'spawn gpg --edit-key $KEY_ID trust quit; send "5\ry\r"; expect eof'

        logk
    fi
fi

# Use pinentry-mac https://github.com/Homebrew/homebrew-core/issues/14737#issuecomment-309547412
echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent

# Tell GnuPG to always use the longer, more secure 16-character key IDs
echo "keyid-format long" >> ~/.gnupg/gpg.conf

if [ -z "$KEY_ID" ]; then
    # Grab KEY_ID for later use
    KEY_ID=$(gpg --list-secret-keys | grep sec | awk '{print substr ($0, 15, 16)}')
fi

# Check GPG config on Git
if [[ $(git config user.signingkey) == "" ]]; then
    # Tell Git about signing key
    log "**************************"
    log "No GPG keys found on Git."
    log "Configuring GPG commit signing..."
    git config --global user.signingkey $KEY_ID
    git config --global commit.gpgsign true
    logk
fi

# Grab GPG key fingerprint from GPG public key
GPG_KEY_FINGERPRINT=`echo $GPG_PUBLIC_KEY 2>/dev/null | gpg --with-colons --import-options show-only --import --fingerprint 2>/dev/null | awk -F: '$1 == "fpr" {print $10}' | head -1`

# Check if revocation certificate already exists
if [[ $(ls ~/.gnupg/openpgp-revocs.d/ | grep $GPG_KEY_FINGERPRINT) == "" || $(ls ~/gnupg/revocable) == "" ]]; then
    log "**************************"
    log "No revocation certificate found."
    logn "Creating a revocation certificate..."
    if [[ $(ls ~/ | grep gnupg) == "" ]]; then # create directory
        mkdir ~/gnupg; mkdir ~/gnupg/revocable
    fi
    gpg --output ~/gnupg/revocable/$GPG_KEY_FINGERPRINT.rev --gen-revoke $KEY_ID
    logk
fi

# Check if public key file already exists
if [[ $(cat ~/public.key 2>/dev/null; echo $?) == "0" ]]; then # file already exists
    logk
else
    log "**************************"
    logn "Exporting your public key block to ~/public.key ..."
    GPG_PUBLIC_KEY=$(gpg --armor --export $KEY_ID)
    echo $GPG_PUBLIC_KEY > ~/public.key
    logk
fi

# Ask if user wants GitHub Desktop installed
log "**************************"
logn "Do you wish to install GitHub Desktop? (helpful if you don't like the command line)  [y / n]: "
read WANTS_GITHUB_DESKTOP

if [[ $WANTS_GITHUB_DESKTOP == "y" ]]; then
    # Install GitHub Desktop
    log "**************************"
    log "Installing GitHub Desktop..."
    brew install github
    log "Select your main GitHub email when asked by GitHub Desktop!"
    logk
fi

# Ask which editor the user wants installed
log "**************************"
logn "Which text editor would you like installed?\n
        1. Visual Studio Code -- great for code, text, and markdown\n
        2. Typora -- great for markdown\n
        3. Atom -- in-between vs code and typora\n
        -------------------------------------------\n
        [ Type 1, 2 or 3 ]: "
read TEXT_EDITOR

# Install an editor

if [[ $TEXT_EDITOR == "1" ]]; then
    log "**************************"
    log "Installing VS-Code"
    brew install visual-studio-code
    if [[ $(git config core.editor) == "" ]]; then
        log "No default editor set for git."
        log "Setting VS-Code as default editor..."
        git config --global core.editor code
    fi
    logk
fi

if [[ $TEXT_EDITOR == "2" ]]; then
    log "**************************"
    log "Installing Typora"
    brew install typora
    echo 'alias typora="open -a typora"' >> ~/.zshrc
    if [[ $(git config core.editor) == "" ]]; then
        log "No default editor set for git."
        log "Setting Typora as default editor..."
        git config --global core.editor typora
    fi
    logk
fi

if [[ $TEXT_EDITOR == "3" ]]; then
    log "**************************"
    log "Installing Atom"
    brew install atom
    if [[ $(git config core.editor) == "" ]]; then
        log "No default editor set for git."
        log "Setting Atom as default editor..."
        git config --global core.editor atom
    fi
    logk
fi

# Add public key to GitHub account
if [ -z "$GH_PUBLIC_KEY" ]; then
    log "FINAL STEP: Add your ~/public.key to your GitHub account:"
    log "Copying your public key..."
    echo $GPG_PUBLIC_KEY | pbcopy
    log "It is copied. Select 'New GPG Key' on the browser and paste it."
    log "Opening https://github.com/settings/gpg/new on the browser..."
    sleep 2s
    open https://github.com/settings/gpg/new

    logn "Type 'y' after you add your public key to GitHub: "
    read ADDED
    if [[ $ADDED == "y" ]]; then
        # Check if the correct key was added
        log "Checking if the correct key was uploaded to GitHub..."
        sleep 5s # wait a bit to make sure we get the most up to date info from github
        GH_PUBLIC_KEY_ADDED=$(curl https://github.com/$GH_USER.gpg 2>/dev/null)
        if [ -z "$GH_PUBLIC_KEY_ADDED" ]; then
            abort "Unable to find your key on GitHub!"
        else
            if [[ $GH_PUBLIC_KEY_ADDED == $GPG_PUBLIC_KEY ]]; then
                logk
            fi
        fi
    fi
fi

log "Cleaning things up..."
brew cleanup

SCRIPT_SUCCESS="1"
log "Enjoy your new development machine!"

exit
