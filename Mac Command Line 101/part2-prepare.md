> Note: This document is an udpated version of the Part 2 of Christopher Allen's [Intro to the Mac Command Line](https://github.com/ChristopherA/intro-mac-command-line).

Part 2 - Preparation and Installation
=====================================

Every Mac supports a large numer of command line tools, however, not every program that you need for development is included by default. This tutorial instructs you on how to prepare and configure your Mac to make it a powerful development system.

You do not need to deeply understand all the commands that are used here — they are explained briefly, but you do not need to learn them yet. I am explaining only because it is YOUR computer and you should know what and why these tools have been added.

System Updates
--------------

The first thing you need to do is to make sure that you have the most recent version of the OS, which as of the writing of this intro is Mac OS X Big Sur 11.5.1. Everything in these introduction files should work on previous version of the the OS, however, when you are doing development work it is important to have the most recent updates for security reasons.

You can get all your system updates by going the the _About This Mac_ item under the Apple Menu, clicking on the _Software Update_ button and pressing the _Update Now_ button. However, you can also do it from the command line.

The `sudo` command is used to run programs that need additional privileges to change your computer, and thus your Mac's administrative password. `/usr/sbin/softwareupdate -l` is the program that checks with Apple's update servers for the most recent version. You may need to execute this command multiple times, or even reboot your system if your Mac is not current.

```
$ cd ~
$ sudo /usr/sbin/softwareupdate -l

WARNING: Improper use of the sudo command could lead to data loss
or the deletion of important system files. Please double-check your
typing when using sudo. Type "man sudo" for more information.

To proceed, enter your password, or type Ctrl-C to abort.

Password:
Software Update Tool
Copyright 2002-2012 Apple Inc.

Finding available software
No new software available.
$
```

Install Apple's Command Line Tools
----------------------------------

Next we are going to install Apple's Command Line Tools, which will install a number of development tools that will be available from the command line. There is a "trick" of touching a file that makes this happen from the command line without loading Apple's XCODE development environment for creating Mac and iOS apps.

Because you've recently entered an administrative password for the `sudo` command, the shell may not ask you for your admin password again.

```
$ touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
sudo /usr/sbin/softwareupdate -ia
Software Update Tool
Copyright 2002-2012 Apple Inc.

Finding available software

Downloading Command Line Tools (OS X 11.5)
Downloaded Command Line Tools (OS X 11.5)
Installing Command Line Tools (OS X 11.5)
Done with Command Line Tools (OS X 11.5)
Done.
$/bin/rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
```

With this installation you have just installed 92 development tools into your /Library/Developer/CommandLineTools/bin/

```
BuildStrings CpMac DeRez GetFileInfo MergePef MvMac ResMerger Rez RezDet RezWack SetFile SplitForks UnRezWack ar as asa bison c++ c89 c99 cc clang clang++ cmpdylib codesign_allocate cpp ctags ctf_insert dsymutil dwarfdump dyldinfo flex flex++ g++ gatherheaderdoc gcc gcov git git-cvsserver git-receive-pack git-shell git-upload-archive git-upload-pack gm4 gnumake gperf hdxml2manxml headerdoc2html indent install_name_tool ld lex libtool lipo lldb llvm-cov llvm-profdata lorder m4 make mig mkdep nasm ndisasm nm nmedit otool pagestuff projectInfo ranlib rebase redo_prebinding resolveLinks rpcgen segedit size strings strip svn svnadmin svndumpfilter svnlook svnrdump svnserve svnsync svnversion unifdef unifdefall unwinddump what xml2man yacc
```

From now on, the Mac App Store's regular System Update will keep these tools current.

Create Some Additional Folders in Home
--------------------------------------

I find it useful to prepare in advance some additional folder in my home "~" directory. The convention I use is that if the folder starts with a Capital, the folder contains items for Finder's GUI. If the folder begins with a lower-case letter (making it faster to type) then it is to be used by the CLI.

All of these folders are optional — many you will not use until much later in this tutorial:

* ~/.dotfiles # This is where I backup my dotfiles (explained later) and store some other useful tools.
* ~/.dotfiles/bin # This is where I keep small command line scripts that I use regularly.
* ~/Applications # This is where I keep any GUI apps that are installed for development purposes separate from those root /Applications folder.
* ~/code # This is where I store the source code from open source repositories from github
* ~/Pool # This is where I store large files that I exclude from backing up on Time Machine. Great for movies, large installer files, etc. that I have backuped up elsewhere or are easily downloaded again from the net.
* ~/projects # This is where I keep repositories of my own source code or others work-in-progress.
* ~/temp # This is where I keep code and projects that are just temporary and can be deleted at any time. I practice here.

```
$ mkdir ~/.dotfiles ~/.dotfiles/bin ~/Applications ~/code ~/Pool ~/projects ~/temp
$ ls -a
.			Desktop			Pictures
..			Documents		Pool
.CFUserTextEncoding	Downloads		Public
.Trash			Library			code
.dotfiles		Movies			projects
Applications		Music			temp

$
```

Installing Brew
---------------

Next we are going to install [Homebrew](http://brew.sh) (known as `brew` for short), a software package manager.

You can consider `brew` to be an app store for open source web apps and developer tools. There are thousands of different open source code bases, all with various dependences on each other, and each requiring different configurations for what kind of computer OS it is running on (Linux, Unix, Mac, Windows, etc.). Brew manages those complexities. If you request to install a particular tool that needs other packages, tools or libraries to run, Brew will first install them in the correct order. Brew also stores its files in some specific ways that are best practices so that different tools don't interfere with each other.

Brew is not installed on your Mac by default, so you'll need to run a script to install it. They provide a script to install it on their github site, which is run by `bash` which is installed on your Mac by default. WARNING: Be cautious whenever someone asks you to run a script that has `curl` command in it, because if the author is malicious they can corrupt your system or make it vulnerable. In this case the script is run from a trusted website (github), and is from a trusted account there (Homebrew). I suggest you go to the [Homebrew](http://brew.sh) website and confirm that this is the correct script to use.

This script may ask you for your administrator password.

```
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
==> This script will install:
/usr/local/bin/brew
/usr/local/share/doc/homebrew
/usr/local/share/man/man1/brew.1
/usr/local/share/zsh/site-functions/_brew
/usr/local/etc/bash_completion.d/brew
/usr/local/Homebrew
==> The following new directories will be created:
/usr/local/Cellar
/usr/local/Homebrew
/usr/local/Frameworks
/usr/local/bin
/usr/local/etc
/usr/local/include
/usr/local/lib
/usr/local/opt
/usr/local/sbin
/usr/local/share
/usr/local/share/zsh
/usr/local/share/zsh/site-functions
/usr/local/var

Press RETURN to continue or any other key to abort
==> /usr/bin/sudo /bin/mkdir -p /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
==> /usr/bin/sudo /bin/chmod g+rwx /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
==> /usr/bin/sudo /bin/chmod u+rwx share/zsh share/zsh/site-functions
==> /usr/bin/sudo /usr/sbin/chown admin /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
==> /usr/bin/sudo /usr/bin/chgrp admin /usr/local/Cellar /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
==> /usr/bin/sudo /bin/mkdir -p /Users/admin/Library/Caches/Homebrew
==> /usr/bin/sudo /bin/chmod g+rwx /Users/admin/Library/Caches/Homebrew
==> /usr/bin/sudo /usr/sbin/chown admin /Users/admin/Library/Caches/Homebrew
==> Downloading and installing Homebrew...
remote: Counting objects: 1033, done.
remote: Compressing objects: 100% (929/929), done.
remote: Total 1033 (delta 95), reused 592 (delta 68), pack-reused 0
Receiving objects: 100% (1033/1033), 1.05 MiB | 508.00 KiB/s, done.
Resolving deltas: 100% (95/95), done.
From https://github.com/Homebrew/brew
 * [new branch]      master     -> origin/master
HEAD is now at 23efbc5 Merge pull request #1051 from woodruffw/cctools-macho-remove
==> Homebrew has enabled anonymous aggregate user behaviour analytics
Read the analytics documentation (and how to opt-out) here:
  https://git.io/brew-analytics
==> Tapping homebrew/core
Cloning into '/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core'...
remote: Counting objects: 3725, done.
remote: Compressing objects: 100% (3617/3617), done.
remote: Total 3725 (delta 15), reused 1247 (delta 0), pack-reused 0
Receiving objects: 100% (3725/3725), 2.91 MiB | 1.13 MiB/s, done.
Resolving deltas: 100% (15/15), done.
Checking connectivity... done.
Tapped 3604 formulae (3,752 files, 9M)
Checking out v1.0.1 in /usr/local/Homebrew...
To checkout master in /usr/local/Homebrew run:
  'cd /usr/local/Homebrew && git checkout master
Already up-to-date.
==> Installation successful!
==> Next steps
Run `brew help` to get started
Further documentation: https://git.io/brew-docs
==> Homebrew has enabled anonymous aggregate user behaviour analytics
Read the analytics documentation (and how to opt-out) here:
  https://git.io/brew-analytics
$
```

After installing Homebrew, the first thing we want to do is confirm that it has been installed correctly, or if there has been something else installed on your Mac previously that will cause problems.

```
$ brew doctor
Your system is ready to brew.
$
```

If there were any errors, `brew doctor` will tell you how to fix them. If what it suggests to fix the problem doesn't work, I find that almost every problem that has come up is a question on the website [StackOverflow](http://stackoverflow.com) so search for your solution there.

Install Git
-----------

The first command line application we will install is [Git](http://git-scm.com), which is the most popular source code version control system. A source code control system helps you manage the production of your code, backup and restore different versions of your code, and work cooperatively with others. `git` is popular because it is open source, it is distributed (i.e. there isn't one master repository the files have to come from), works with projects as large as the Linux operating system with thousands of contributors, small team projects, and yet is useful for even for a single programmer.

We will use `brew` to install git, so always before we brew anything we want to make sure that `brew` is current. We just installed it so we don't really need to do this now, but I will demonstrate best practices (everything after a # is a comment):

```
$ brew doctor # run self test to see if brew is running properly
Your system is ready to brew.
$ brew update # update brew itself to the latest version, and get latest list of apps
Already up-to-date.
$ brew upgrade # upgrade any apps managed by brew to the most recent version
$
```

Next we wil confirm information about git, then we install it.

```
$ brew info git
git: stable 2.3.5 (bottled), HEAD
http://git-scm.com
/usr/local/Cellar/git/2.3.5 (1363 files, 31M) *
Not installed
From: https://github.com/Homebrew/homebrew/blob/master/Library/Formula/git.rb
```

```
$ brew install git
==> Downloading https://homebrew.bintray.com/bottles/git-2.3.5.yosemite.bottle.t
######################################################################## 100.0%
==> Pouring git-2.3.5.yosemite.bottle.tar.gz
==> Caveats
The OS X keychain credential helper has been installed to:
  /usr/local/bin/git-credential-osxkeychain

The "contrib" directory has been installed to:
  /usr/local/share/git-core/contrib

Bash completion has been installed to:
  /usr/local/etc/bash_completion.d

zsh completion has been installed to:
  /usr/local/share/zsh/site-functions
==> Summary
🍺  /usr/local/Cellar/git/2.3.5: 1363 files, 31M
```

```
$ git --version
git version 2.3.5
$
```

Now, configure your local git credentials (use your GitHub account actual name and email information):

```
$ git config --global user.name "Your Name"
$ git config --global user.email your.github@email.com
```

Squelch git 2.x warning message when pushing:

```
git config --global push.default simple
```

Installing GitHub CLI
---------------------

[GitHub CLI](https://cli.github.com/) brings GitHub to your terminal. It includes a set of features and commands to facilitate your interaction with GitHub. It allows you to work with issues, pull requests, checks, releases, and more directly in your terminal. You can find all the available `gh` commands in the [online manual](https://cli.github.com/manual/) and some `gh` tips [here](https://gist.github.com/ChristopherA/3cca24936fb2c84786a29f67bacacd3e).

Install `gh` with `brew`:
```
$ brew install gh
```
Then, you can easily authenticate with your GitHub account with:
```
$ gh auth login
```

It will prompt you for some information.

If you want to log into a personal account, select `GitHub.com`.

Select your preferred auth method. Selecting `SSH` will help you create [ssh keys for usage with GitHub](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh). You can then select "upload your SSH public key to your GitHub account."

When asked how to authenticate, select "Paste an authentication token." Open your [tokens section on GitHub](https://github.com/settings/tokens), click _Generate new token_. Now you need to give it a descriptive name, like _github cli_ for example and select its permissions. `gh` requires at least three: `repo`, `read:org` and `admin:public_key`. Select those, and any additional ones if you so wish, and hit create! Now you just need to copy that token and paste it into the terminal. _Do not close the browser window before copying the token! This is your only chance to copy it, it will disapear afterwards. If you mess up, generate a new token._

You should be set up with `gh` by now!

Set Up GPG
----------

You should now set up GPG for commit signature verification. Just refer to [this guide](../gpg-with-github.md) and set it up before moving forward!

Installing Casks
----------------

[Homebrew Cask](https://github.com/Homebrew/homebrew-cask) extends Homebrew to allow the installation of GUI applications on a Mac. I find it particularly useful for installing those developer apps that require an installer or a .dmg file. Homebrew Cask will automatically verify the download's checksums for you. One other useful thing that it does is that it puts the app into your ~/Applications folder, keeping them seperate from your other apps.

Cask is already built into Homebrew, so you don't need to install anything else. In order to install a GUI app (a Cask), for example the productivity app Alfred, you can just do:

```
$ brew install alfred
==> Downloading https://cachefly.alfredapp.com/Alfred_4.2.1_1187.dmg
######################################################################## 100.0%
==> Verifying SHA-256 checksum for Cask 'alfred'.
==> Installing Cask alfred
==> Moving App 'Alfred 4.app' to '/Applications/Alfred 4.app'.
🍺  alfred was successfully installed!
```

Uninstalling Casks
------------------

It is as easy to uninstall a Cask as it was to install it:
```
$ brew uninstall alfred
```
This will uninstall the Cask and remove the application which was moved to `/Applications`.

Installing the Atom Text Editor
-------------------------------

Next we are going to use `brew` to install the Atom text editor. There are many powerful command line text editors out there (and a constant battle between fans of emacs vs those for vim), but learning them is outside the scope of this tutorial. In the meantime there is a very powerful, free and open source GUI text editor optimized for command line and web developers called Atom. One of its best features is its integration with Git.

We will install it with `brew`

```
$ brew install atom
==> Downloading https://atom.io/download/mac
######################################################################## 100.0%
==> Symlinking App 'Atom.app' to '/Users/ChristopherA/Applications/Atom.app'
==> Symlinking Binary 'apm' to '/usr/local/bin/apm'
==> Symlinking Binary 'atom.sh' to '/usr/local/bin/atom'
🍺  atom staged at '/opt/homebrew-cask/Caskroom/atom/latest' (11288 files, 239M)
$
```

From now own instead of using the `open` command to edit a text file, we will use `atom`, for example:

```
$ touch ~/temp/temp.txt
$ atom ~/temp/temp.txt
```
You can now edit this file using the familar Mac GUI experience.

Installing the Typora Markdown Editor
-------------------------------------

[Typora](https://typora.io/) is a distraction-free Markdown editor and reader. One cool thing about it is that it seamlessly provides you with a live preview as you type. So although you're typing in Markdown, you see the result in real time. This can be very useful to make sure you're writing what you're intending to write.

We can download Typora as a `brew` Cask as well:
```
$ brew install typora
```
Similar to Atom, you can open a file into Typora directly in the command line. But it isn't as simple:
```
$ touch ~/temp/temp2.txt
$ open -a typora ~/temp/temp2.txt
```
You can create a persistent alias for that in your configuration file:
```
$ echo 'alias typora="open -a typora"' >> ~/.zshrc
$ source ~/.zshrc
```
`echo` writes any argument passed into the standard output. In this case, we want it to write to our configuration file `~/.zshrc`, so we tell it so with `>>` to define where we want the output to go. It will then write a line at the end of the specified file, containing what we put under `' '`.

We do `source ~/.zshrc` to refresh our configuration file. The system will pull the most recent version of our file and update its configurations. We need to do that so the system becomes aware of our newly defined alias.

Now you can just do:
```
$ touch ~/temp/temp3.txt
$ typora ~/temp/temp3.txt
```

Web Get
-------

I find the `wget` tool to be very useful. Point it to a URL and it downloads the contents to a file. You can also do this with the built-in `curl` tool, but I find `wget` very useful at times.

```
$ brew install wget
==> Installing wget dependency: openssl
==> Downloading https://homebrew.bintray.com/bottles/openssl-1.0.2a-1.yosemite.bottle.tar.gz
######################################################################## 100.0%
==> Pouring openssl-1.0.2a-1.yosemite.bottle.tar.gz
==> Caveats
A CA file has been bootstrapped using certificates from the system
keychain. To add additional certificates, place .pem files in
  /usr/local/etc/openssl/certs

and run
  /usr/local/opt/openssl/bin/c_rehash

This formula is keg-only, which means it was not symlinked into /usr/local.

Mac OS X already provides this software and installing another version in
parallel can cause all kinds of trouble.

Apple has deprecated use of OpenSSL in favor of its own TLS and crypto libraries

Generally there are no consequences of this for you. If you build your
own software and it requires this formula, you'll need to add to your
build variables:

    LDFLAGS:  -L/usr/local/opt/openssl/lib
    CPPFLAGS: -I/usr/local/opt/openssl/include

==> Downloading https://www.geotrust.com/resources/root_certificates/certificates/Equifax_Secure_
######################################################################## 100.0%
==> /usr/local/Cellar/openssl/1.0.2a-1/bin/c_rehash
==> Summary
🍺  /usr/local/Cellar/openssl/1.0.2a-1: 463 files, 18M
==> Installing wget
==> Downloading https://homebrew.bintray.com/bottles/wget-1.16.3.yosemite.bottle.tar.gz
######################################################################## 100.0%
==> Pouring wget-1.16.3.yosemite.bottle.tar.gz
🍺  /usr/local/Cellar/wget/1.16.3: 9 files, 1.5M
Aeguss-MacBook-Pro:intro-mac-command-line ChristopherA$
```

Install GitHub Desktop
----------------------

:warning: Before moving forward, make sure you have done everything in this guide and have also done [GPG configuration](../gpg-with-github.md). Particularly, make sure you opted to _enable GPG signing for all repositories using the --global flag in that tutorial._ If you are certain you have gone through all the steps to set up GPG but can't remember if you enabled GPG signing for your commits globally or not, you can quickly open a Terminal window and type: `

If you do not enjoy using the command line, you can contribute to open source software using GitHub Desktop, which you can download as a `brew` Cask.
```
$ brew install github
==> Downloading https://desktop.githubusercontent.com/releases/2.9.0-4806a6dc/GitHubDesktop-x64.zip
==> Installing Cask github
==> Moving App 'GitHub Desktop.app' to '/Applications/GitHub Desktop.app'
==> Linking Binary 'github.sh' to '/usr/local/bin/github'
🍺  github was successfully installed!
```
You will then be able to find the GitHub Desktop application in your `/Applications` folder. Go ahead and give that a double-click and open it. It will prompt for you to sign in, which you should do. It will open a window in your default browser, through which you will be requested to sign into your GitHub account. Do that and authorize GitHub Desktop to obtain your GitHub profile information.

Now, before moving forward, go to GitHub Desktop's _Preferences_ (you can use the `Cmd + ,` shortcut within the app). Under _Account_, you should be signed in. Now, head over to _Git_ in the same window and _make sure your selected email matches both your committer email and your GPG key email!_ If it doesn't, change it for the one that does.

If you have set up brew, git, gh, github desktop, ssh, (basically everything in this guide so far) correctly, you will be able to work with GitHub and contribute to open source projects using the nice UX of GitHub Desktop –– and your commits will be automatically signed!

Brew Cleanup
-------------------

Ater we `brew` anything it is best practices to tell brew to cleanup. You don't have to do this after each item brew, you can brew a number of items at once and only cleanup after.

```
$ brew doctor
Your system is ready to brew.
$ brew cleanup
Removing: /Library/Caches/Homebrew/Cask/atom--1.56.0.zip... (202.6MB)
```

Final Cleanup
-------------

The locate and whathis databases, used by the command line utilities `locate`, `whatis` and `apropos`, are only generated weekly, so run this after adding any commands to update the database. This will happen in the background and can take some time to generate the first time.

```
$ sudo periodic daily weekly monthly
```