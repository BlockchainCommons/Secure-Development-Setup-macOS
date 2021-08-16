#!/bin/bash

##  Install Git, GitHub CLI, GPG, GitHub Desktop, text editor

##  [WIP] Not suitable for deployment yet.
#   TODO:
#   - [ x ] Finish first draft
#   - [ x ] Test first working solution
#   - [ ] Refactor script (https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/)
#   - [ ] Test refactored, final script

##  Part of the code in this script came from or was adapted from:
#  * https://github.com/MikeMcQuaid/strap/blob/master/bin/strap.sh
#  * https://github.com/BlockchainCommons/Secure-Development-Setup-macOS/blob/master/initial-macos-developer-setup.sh

# Exit script if any subsequent command fails
set -e

# OSX-only stuff. Abort if not OSX.
if [[ "$(uname -s)" != "Darwin" ]]; then
  printf "This script is only for OSX!\n"
  exit 1
fi

# Do not run script as root
[[ "$USER" = "root" ]] && abort "Run this script as yourself, not root."
groups | grep $Q -E "\b(admin)\b" || abort "Add $USER to the admin group."

# Ask for git credentials
echo "**************************"
echo "Make sure you have already created your GitHub account online and verified your email!"
printf "What's your GitHub username? "
read GITHUB_NAME
printf "What's your GitHub account email? "
read GITHUB_EMAIL


# Install and setup Git
if [[ $(command -v git) == "" ]]; then
    echo "**************************"
    printf "Downloading and installing Git\n"
    brew install git
    printf "Configuring Git\n"
    git config --global user.name "$GITHUB_NAME"
    git config --global user.email $GITHUB_EMAIL

    # Squelch git 2.x warning message when pushing
    if ! git config push.default >/dev/null; then
        git config --global push.default simple
    fi
fi

# Install and setup gh
if [[ $(command -v gh) == "" ]]; then
    echo "**************************"
    printf "Downloading and installing GitHub CLI\n"
    brew install gh
    echo "**************************"
    printf "FOLLOW THE STEPS BELOW TO CONFIGURE GITHUB CLI:\n"
    printf "This will be interactive. Here's what you need to select and/or type through the configuration process:\n"
    printf "1. Select GitHub.com if you're setting up a personal account.\n"
    printf "2. Select your preferred authentication method. Selecting SSH will help you create SSH keys for usage with GitHub. You can then select 'upload your SSH public key to your GitHub account.'\n"
    printf "3. Select 'Paste an authentication token.' You will need to head over to your tokens section on GitHub at: https://github.com/settings/tokens \n"
        printf "3a. Click 'Generate new token' and give it a descriptive name, for instance 'github cli' \n"
        printf "3b. Allow the following 3 permissions by checking their individual boxes: repo, read:org, admin:public_key \n"
        printf "3c. Hit create and COPY THE TOKEN! You will need to paste it into the terminal when prompted for. \n"
    gh auth login
fi

echo "**************************"
printf "Do you wish to have new GPG keys created for you and configured for usage with Git? y / n: "
read WANTS_GPG

if [[ $WANTS_GPG == "y" ]]; then
    # Install and setup GPG with GitHub
    if [[ $(command -v gpg) == "" ]]; then
        
        echo "**************************"
        printf "Downloading and installing GPG and pinentry-mac.\n"
        brew install gnupg pinentry-mac
        
        # Configure pinentry-mac
        echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
        echo 'export GPG_TTY=$(tty)' >> ~/.zshrc
        
        # Tell GnuPG to always use the longer, more secure 16-character key IDs
        echo "keyid-format long" >> ~/.gnupg/gpg.conf
        
        echo "**************************"
        printf "FOLLOW THE STEPS BELOW TO CREATE & CONFIGURE GPG:\n"
        printf "This will be interactive. You can press 'return' / 'enter' to accept the defaults on the first two steps.\n"
        printf "On the third step, select make the key expire in one year by typing 1y\n"
        printf "When asked your email address, provide the one you use with GitHub!\n"
        printf "For your passphrase, grab a dice and refer to: https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt \n"
        printf "Rolling the dice 5 times will give you one word -- you need 6 words so do that 6 times!\n"
        printf "Type in your new passphrase afterwards and make sure you don't forget it! Create a written backup on a secure location if needed!\n"
        gpg --full-generate-key

        # Grab KEY_ID for later use
        KEY_ID=$(gpg --list-secret-keys | grep sec | awk '{print substr ($0, 15, 16)}')

        echo "**************************"
        printf "Creating a revocation certificate\n"
        if [[ $(cd; ls | grep gnupg) == "" ]]; then # create directory
            mkdir ~/gnupg; mkdir ~/gnupg/revocable
        fi
        gpg --output ~/gnupg/revocable/revoke.asc --gen-revoke $KEY_ID

        echo "**************************"
        printf "Exporting your public key block to ~/public-key.txt \n"
        gpg --armor --export $KEY_ID > ~/public-key.txt
        printf "IMPORTANT: Add the contents of ~/public-key.txt to your GitHub account > Settings > SSH and GPG keys > New GPG key\n\n"

        echo "**************************"
        printf "Telling git about your signing key locally\n"
        git config --global user.signingkey $KEY_ID

        echo "**************************"
        printf "Set commit signing in all repos by default\n"
        git config --global commit.gpgsign true

        echo "**************************"
        printf "WARNING:\n"
        printf "REMEMBER TO ADD YOUR PUBLIC KEY BLOCK TO YOUR GITHUB ACCOUNT BEFORE SIGNING COMMITS!\n"
        printf "Add the contents of ~/public-key.txt to your GPG keys in your GitHub account configurations\n"
    fi
fi

# Ask if user wants GitHub Desktop installed
echo "**************************"
echo "Do you wish to install GitHub Desktop? (an option if you don't like the command line)  y / n: "
read WANTS_GITHUB_DESKTOP

if [[ $WANTS_GITHUB_DESKTOP == "y" ]]; then
    # Install GitHub Desktop
    echo "**************************"
    printf "Installing GitHub Desktop\n"
    brew install github
    printf "Nice! You now have GitHub Desktop installed. Now, go ahead and open it to make sure your email address there, under Preferences > Account, is the same as your GitHub email account!"
    printf "If the email addresses match, congrats! You can now contribute to open source with signed commits using only GitHub Desktop."
fi

# Ask which editor the user wants installed
echo "**************************"
printf "Which text editor would you like installed?\n
        1. VS Code -- great for code, text, and markdown\n
        2. Typora -- great for markdown\n
        3. Atom -- in-between vs code and typora\n
        -------------------------------------------\n
        [ Type 1, 2 or 3 ]: "
read TEXT_EDITOR

if [[ $TEXT_EDITOR == "1" ]]; then
    echo "**************************"
    printf "Installing VS Code\n"
    brew install visual-studio-code
fi

if [[ $TEXT_EDITOR == "2" ]]; then
    echo "**************************"
    printf "Installing Typora\n"
    brew install typora
    echo "alias typora='open -a typora'"
fi

if [[ $TEXT_EDITOR == "3" ]]; then
    echo "**************************"
    printf "Installing Atom\n"
    brew install atom
fi

echo "**************************"
echo "Cleaning up..."
brew cleanup
source ./zshrc