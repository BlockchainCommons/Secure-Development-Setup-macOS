#!/bin/bash

##  Install Git, GitHub CLI, GPG, GitHub Desktop, text editor

##  [WIP] Not suitable for deployment yet.
#   TODO:
#   - [ ] Finish first draft
#   - [ ] Test first working solution
#   - [ ] Refactor script (https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/)
#   - [ ] Test refactored, final script

##  Part of the code in this script came from or was adapted from:
#  * https://github.com/MikeMcQuaid/strap/blob/master/bin/strap.sh
#  * https://github.com/BlockchainCommons/Secure-Development-Setup-macOS/blob/master/initial-macos-developer-setup.sh

# Exit script if any subsequent command fails
set -e

# OSX-only stuff. Abort if not OSX.
if [ "$(uname -s)" != "Darwin" ]
then
  printf "This script is only for OSX!\n"
  exit 1
fi

# Do not run script as root
[ "$USER" = "root" ] && abort "Run this script as yourself, not root."
groups | grep $Q -E "\b(admin)\b" || abort "Add $USER to the admin group."

# Ask for git credentials
echo "**************************\n"
echo "Make sure you have already created your GitHub account online and verified your email!"
echo "What's your GitHub account name? "
read GITHUB_NAME
echo "What's your GitHub account email? "
read GITHUB_EMAIL


# Install and setup Git
if [ $(command -v git) == "" ]; then
    echo "**************************\n"
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
if [ $(command -v gh) == "" ]; then
    echo "**************************\n"
    printf "Downloading and installing GitHub CLI\n"
    brew install gh
    echo "**************************\n"
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

echo "**************************\n"
echo "Do you wish to have new GPG keys created for you and have them linked to your GitHub account? y / n: "
read WANTS_GPG

if [ $WANTS_GPG == "y" ]; then
    # Install and setup GPG with GitHub
    if [ $(command -v gpg) == "" ]; then
        echo "**************************\n"
        printf "Downloading and installing GPG.\n"
        brew install gnupg pinentry-mac
        echo "**************************\n"
        printf "FOLLOW THE STEPS BELOW TO CREATE & CONFIGURE GPG:\n"
        printf "This will be interactive. You can press 'return' / 'enter' to accept the defaults on the first two steps.\n"
        printf "On the third step, select make the key expire in one year by typing 1y\n"
        printf "When asked your email address, provide the one you use with GitHub!\n"
        printf "For your passphrase, grab a dice and refer to: https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt \n"
        printf "Rolling the dice 5 times will give you one word -- you need 6 words so do that 6 times!\n"
        printf "Type in your new passphrase afterwards and make sure you don't forget it! Create a written backup on a secure location if needed!"
        gpg --full-generate-key

        echo "**************************\n"
        printf "Creating a revocation certificate\n"
        # TODO: create folder first
        gpg --output ~/gnupg/revocable/revoke.asc --gen-revoke $GITHUB_EMAIL

        echo "**************************\n"
        printf "Exporting your public key block to ~/public-key.txt \n"
        gpg --armor --export $GITHUB_EMAIL > ~/public-key.txt
        printf "IMPORTANT: Add the contents of ~/public-key.txt to your GitHub account > Settings > SSH and GPG keys > New GPG key\n\n"

        echo "**************************\n"
        printf "Telling GPG to always use long key formats\n"
        echo "keyid-format long" >> ~/.gnupg/gpg.conf

        echo "**************************\n"
        printf "Telling git about your signing key locally\n"
        # TODO: grab KEY_ID from gpg --list-secret-keys with awk
        git config --global user.signingkey $KEY_ID

        echo "**************************\n"
        printf "Set commit signing in all repos by default\n"
        git config --global commit.gpgsign true
    fi
fi

# Ask if user wants GitHub Desktop installed
echo "**************************\n"
echo "Do you wish to install GitHub Desktop? (an option if you don't like the command line)  y / n: "
read WANTS_GITHUB_DESKTOP

if [ $WANTS_GITHUB_DESKTOP == "y" ]; then
    # Install GitHub Desktop
    echo "**************************\n"
    printf "Installing GitHub Desktop\n"
    brew install github
    printf "Nice! You now have GitHub Desktop installed. Now, go ahead and open it to make sure your email address there, under Preferences > Account, is the same as your GitHub email account!"
    printf "If the email addresses match, congrats! You can now contribute to open source with signed commits using only GitHub Desktop."
fi

# Ask which editor the user wants installed
echo "**************************\n"
echo "Which text editor would you like installed?\n
        1. VS Code -- great for code, text, and markdown\n
        2. Typora -- great for markdown\n
        3. Atom -- in-between vs code and typora\n
        -------------------------------------------\n
        [1, 2 or 3]: "
read TEXT_EDITOR

if [ $TEXT_EDITOR == "1" ]; then
    echo "**************************\n"
    printf "Installing VS Code\n"
    brew install visual-studio-code
fi

if [ $TEXT_EDITOR == "2" ]; then
    echo "**************************\n"
    printf "Installing Typora\n"
    brew install typora
fi

if [ $TEXT_EDITOR == "3" ]; then
    echo "**************************\n"
    printf "Installing Atom\n"
    brew install atom
fi

echo "**************************\n"
echo "Cleaning up...\n"
brew cleanup