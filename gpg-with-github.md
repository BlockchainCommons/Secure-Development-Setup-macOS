# GPG Signing GitHub Commits

GitHub allows you to use GPG to sign commits. You can use an existing GPG key or generate a new one.

> **New to GitHub and git?** Start by [creating your account](https://github.com/) and reading an [introductory tutorial](https://guides.github.com/activities/hello-world/). If you learn best by doing, check out this [git immersion guided tour](https://gitimmersion.com/).

You can find GitHub's official documentation about GPG commit signature verification [here](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/about-commit-signature-verification#gpg-commit-signature-verification). And here's a [GPG cheatsheet](http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/).

### Install GPG

Install GPG command line tools and pinentry-mac with Brew:

```
$ brew install gnupg pinentry-mac
```

>:warning: Make sure you have [verified your GitHub email](https://docs.github.com/en/articles/verifying-your-email-address) and [set your commit email address](https://docs.github.com/en/articles/setting-your-commit-email-address) before continuing.​ 

> :information_source: Reference [this guide](https://riseup.net/en/security/message-security/openpgp/gpg-best-practices) for best practices on GPG including keyservers, key configuration, and backups. If you are somewhat tech-savvy and what to take the next step towards a more secure and robust GPG key setup, consider using a [YubiKey](https://github.com/drduh/YubiKey-Guide).

Now we can begin. But you might first check if you already have a GPG key in your machine. If you're sure you don't already have any, skip to "Associating an Email Address With Your GPG Key."

## Check for Existing GPG Keys

To check if you already have any GPG keys, open the Terminal and type:
```
$ gpg --list-secret-keys --keyid-format=long
```

If the command outputs no GPG keys, move on to the next step. But if there's at least one GPG keypair shown, and you'd like to use one of them, pick the one you'd like to use with GitHub and _grab its key ID_ (it will be in the `sec` line, after the algorithm, for example, `ec25519/Your-Key-ID-Number`).

Make sure you use _the same_ key pair for _all_ of the steps below. To make things easier, you can save its key ID to a variable. Substitute the "your-key-id" with the key you copied above (you can just do Command + V on the keyboard to paste it after the equal sign):

```
KEY_ID=your-key-id
```

Now you'll be able to reference that key ID with `$KEY_ID` in the terminal. You can then skip the next section and move to "Associate an Address With Your GPG Key."

> Note: For all commands, don't type the '$' sign -- it is used simply to reference that we're using a terminal. However, in '$KEY_ID' you need to type it, since it is used to access the variable's value.

## Don't Have a GPG Key? Create One

Make sure you have the latest version of GPG installed in your machine:

```
$ brew upgrade gnupg
Warning: gnupg 2.3.1_1 already installed
Warning: pinentry-mac 1.1.1.1 already installed
```

Generate a new key pair:

```
$ gpg --full-generate-key
gpg (GnuPG) 2.3.1; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (9) ECC (sign and encrypt) *default*
  (10) ECC (sign only)
  (14) Existing key from card
Your selection? 
```

The latest version of GnuPG has `ECC` as the default key type. You can press `return` to accept it.

```
Please select which elliptic curve you want:
   (1) Curve 25519 *default*
   (4) NIST P-384
   (6) Brainpool P-256
Your selection?
```

Accept the default here again by pressing `return`. Curve 25519 is notably [more secure](https://safecurves.cr.yp.to/) than NIST P-384 and Brainpool P-256.

```
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 
```

You should set your key to expire by 2 years or less after creation date, per [GPG best practices](https://help.riseup.net/en/security/message-security/openpgp/best-practices). For simplicity, type either `2y` or `1y` into the Terminal window. Type `y` when asked for confirmation.

> **Note:** since you will likely not remember to extend your key's lifetime, set a calendar reminder for that. Make it so that it reminds you one month or more before the expiry date -- you likely don't want to do that on a rush. If you do end up forgetting somehow, and it expires, you would still be able to extend it -- so no need to create a new key just because of that.

Now you need to provide your user ID information.

```
GnuPG needs to construct a user ID to identify your key.

Real name: 
```

Type your desired name. Then, type in your email address.

> :warning: Make sure you type the email address which you use with GitHub and is set as your commit email address. This will make it a lot easier going forward, since GitHub will check if all email addresses match for marking your commit as verified. If the emails don't match, the commit may show "unverified" status even though it was signed!

Do not provide a comment -- press `return` and skip it. Your user ID will be prompted and you'll be asked for confirmation, press `o` or `q` to confirm and move forward.

Pinentry-mac will now likely ask for a passphrase. You should pick a secure yet memorable one. Since our human brains are [bad](http://people.ischool.berkeley.edu/~nick/aaronson-oracle/) at entropy and randomness, follow these steps:

1. Grab a dice and open up [EFF's word list](https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt).
2. Your passphrase should consist of at least 4 but _ideally 6 words_. You need 5 dice rolls for each word.
3. So roll the dice 5 times and that, in order, will give you your first word by matching it on EFF's word list.
4. Do that 6 times and you will have a secure and memorable passphrase to use with your new GPG key. Make sure you don't forget it! You can also have a physical backup of that passphrase on paper -- just make sure you store it in a secure place.

Now, tell GnuPG to use only the longer, more secure 16-character GPG key IDs:

```
$ echo "keyid-format long" >> ~/.gnupg/gpg.conf
```

### Configure Pinentry-Mac

You need [some additional configuration](https://github.com/Homebrew/homebrew-core/issues/14737#issuecomment-309547412) to use pinentry-mac instead of the terminal to type your passphrase and save your passphare in your Mac's keychain:

```
$ echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
$ killall gpg-agent
```

### Generate a Revocation Certificate

Although optional, creating a revocation certificate right after creating your GPG key is very useful -- and recommended. It guards you against and prepares you for the undesired scenario of forgetting your passphrase or losing your private key.

If that happens, you can publish your revocation certificate in your website or your GitHub profile, for instance, and let others know that your now defunct keys should no longer be used. It will warn others that your public key should no longer be used for encrypting a message or document.

However, even after publishing your revocation certificate, others will still be able to verify signatures made by you in the past using your revoked public key. And you will still also be able to decrypt messages and documents sent to you in the past if you still have access to your private key related to your revoked public key.

To generate the revocation certificate, you will need your GPG key's user ID information -- either name, email, or the key ID. So open up a Terminal window and type one of the following, depending on the info you choose to feed the command with:

```
$ gpg --output ~/gnupg/revocable/revoke.asc --gen-revoke "Your Name"
```
OR
```
$ gpg --output ~/gnupg/revocable/revoke.asc --gen-revoke your.email@example.com
```
OR
```
$ gpg --output ~/gnupg/revocable/revoke.asc --gen-revoke keyID
```
If you can't remember, you can grab your KeyID with the command `gpg --list-secret-keys --keyid-format=long`. It will be next to `sec`, right after the key type you have, for example `rsa2048/<your-key-id>`.

> Optionally, use the automated command `KEY_ID=$(gpg --list-secret-keys | grep sec | awk '{print substr ($0, 15, 16)}')` to save your key ID into the variable `KEY_ID`, accessible in the terminal with `$KEY_ID`.

You might be asked the reason for creating the revocation certificate. You can just type 0 for "no reason specified" and then, if you like, enter some description. Then you can confirm it and your revocation certificate will be generated.

> Note: Your passphrase might be asked! If so, just type it in and hit `return`. You can also select "save it in keychain" if you don't want to type it every time.

You might want to print a hardcopy of the certificate and keep it somewhere safe (somewhere you keep sensitive documents). But note that the printer itself might be a compromise.

If someone gets access to your key's revocation certificate, they will be able to revoke your key, so keep it safe. _But_ if they happen to get access to your private key as well, then having them get access to your revocation certificate is a desirable thing.

### Grab the Key ID

Grab the GPG key ID from the key pair which you created or selected in previous steps.

If you only have one secret key in your machine, type the following in a Terminal window:

```
$ KEY_ID=$(gpg --list-secret-keys | grep sec | awk '{print substr ($0, 15, 16)}')
```

If you have more than one secret key, you can always use the `gpg --list-secret-keys` command and grab (copy) the desired key's ID manually. It will be in the `sec` line, after the algorithm, for example, `ec25519/Your-Key-ID-Number`. Now, set it to a variable if you grabbed it manually (paste the key-id in the place of "your-key-id"):

```
$ KEY_ID=your-key-id
```

Great, now your key ID can be easily accessed with `$KEY_ID`.

## Associate an Email Address With Your GPG Key

In this section, you will be associating an email address with your selected GPG key. This is important for some reasons, but for this guide's purpose _it allows GitHub to check if your GitHub account's verified email address matches both your committer identity and the email address associated with your GPG key_.

> Note: if you have followed along and created your GPG key in the previous section, you _already_ have associated an email address with your key -- so you should skip this section.

1. On the Terminal, type the command `gpg --edit-key $KEY_ID`

4. To edit your user ID information, type:

    `$ gpg> adduid`
    
    This assumes your GPG key does not yet have an user ID associated with it!
    
    It will prompt and ask for your name, email address, and other comments. You can modify your entries by choosing `N`, `C`, or `E`.
    
    > :warning: Make sure you're using the same email in your GPG key and your GitHub account. GitHub will check and see if they match when you try signing commits with your GPG key. You might need to check or [set your commit email address](https://docs.github.com/en/articles/setting-your-commit-email-address) if you haven't already.
    
    Confirm your selections by entering `O`.

3. Enter your key's passphrase, if it has one.

6. Enter `gpg> save` to save your changes.

## Add Your GPG Key to Your GitHub Account

Now that you have already created your GPG key pair and associated an email with it, you can move forward to add it to your GitHub account!

But first, export your GPG key block.

```
$ gpg --armor --export $KEY_ID
```

OR

```
$ gpg --armor --export "Your Name"
```

OR

```
$ gpg --armor --export your.email@example.com
```

Pick _one_ of the above depending on the user ID info you find simpler to provide the command. It will print your GPG key in ASCII armor format. Copy your entire public key block, including the begin and end indications.

```
-----BEGIN PGP PUBLIC KEY BLOCK-----

       < Your Public Key >

-----END PGP PUBLIC KEY BLOCK-----
```

Now, follow these steps:

1. Log into your GitHub account, navigate to the upper-right hand corner to click your profile photo, then click **Settings**

    ![](https://i.imgur.com/WgLgUf2.png)

2. In the **Account Settings** left sidebar, scroll down a bit and click **SSH and GPG Keys**

    ![](https://i.imgur.com/6MPcLxS.png)

3. Click the green **New GPG key** button on the **GPG Keys** section

    ![](https://i.imgur.com/zTyZB6t.png)

4. In the "Key" field, paste the GPG key you copied. Make sure you paste the entire public key block, which, as the field reads, begins with `----BEGIN PGP PUBLIC KEY BLOCK----`.

    ![](https://i.imgur.com/i9mUwQr.png)

5. Click the green **Add GPG key** button. It will then prompt and ask for your GitHub password to confirm the action.

For future, easier reference of your public key, you might want to save it to a file:

```
gpg --armor --export $KEY_ID > ~/public.key
```

## Telling Git About Your GPG Signing Key

To sign commits locally, you need to tell Git what GPG key you would like to use.

Set your GPG signing key for Git. Paste the command below, substituting `keyID` for your key ID:

```
$ git config --global user.signingkey $KEY_ID
```
Note that the above command will set that key as your signing key for all repositories. This is usually what you'd want, but if you want to set it only for a specific repository: navigate to that repository and remove the `--global` flag.

## Signing Commits

There are some different scenarios as to how you can sign commits.

You can either sign an individual commit; tell Git you want all future commits in the repo you're in to be automatically signed; or set commit signing as default for all repos in your account.

> Note: Your passphrase might be asked on each commit and signing. If so, just type it in and hit `return`. You can also select "save it in keychain" if you don't want to type it every time you commit.

To sign all commits by default in all repos:

```
$ git config --global commit.gpgsign true
```

To sign individual commits:
```
$ git commit -S -m "commit message"
```

To sign all commits by default in current repo:
```
$ git config commit.gpgsign true
```

## Signing Past Commits

If you ever forget to sign a commit only to realize it after, don't worry –– you can sign a past commit. And there are a couple of different ways to achieve this!

### Method 1

The best and easiest way to change your commit history is via interactive rebase.

First, make sure you are in the correct repository, that is, the repository in which the commit you want to change/sign is.

It might also be helpful if you make sure you've set automatic commit signing for _at least_ that repo. Best if set for all repos.

If you want to sign the third commit behind the HEAD:
```
$ git rebase -i HEAD~3

pick 80c35e5 building without umbrella headers or absolute paths
pick 90ad8f2 ok
pick 3239112 ok

# Rebase a62028d..3239112 onto a62028d (3 commands)
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
# d, drop = remove commit
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```
We can for example reword the unsigned commit by changing `pick` to `reword` infront of it. 

Because we are changing that commit all the subsequent commits will automatically change and get a new signature.

The process is interactive, so it will tell you what to press:
Press CTRL + x to save, Are you certain? Press Y
Now edit the commit message and save with CTRL + x. The console will now offer you to enter password of your encrypted GPG key


At the end the output should look like so:

```
$ git rebase -i HEAD~3
[detached HEAD 8c2b5f7] ok.
 Date: Wed Mar 10 00:31:52 2021 +0100
 1 file changed, 3 insertions(+)
Successfully rebased and updated refs/heads/wasm_test.
```

If you now force push the repo:

```
$ git push -f
```

Github will show you that all commits are signed (all those that are on top of the reworded one).

### Method 2

If method 1 didn't work, you can 
This works but the starting commit has to be 1 before the first commit that needs to be fixed.

`git filter-branch -f --commit-filter 'git commit-tree -S "$@";' ea9083e8d80a611e90263ec827298fc79b0c13aa..HEAD`

where you replace ea9083... with your commit hash - the commit BEFORE the one you need to fix

if too many broken commits, first do
`git reset <commit>`
to get back to the last commit you want to keep
then filter-branch as above to resign from commit from before first commit to fix to HEAD
this step not necessary. I did it since I had 18 resigned commits as I kept trying things that were skipping the commit I actually needed to fix. So to remove those I reset back... If you don't want to lose the commits in between, don't do this.

THEN you must force push
`git push origin branchname -f`



## Troubleshooting

Some things you can try depending on what is not working as expected.

- In general terms, you may need to sign a test message for settings to sync and/or pinentry-mac save your passphrase. The following will likely prompt for your passphrase, type it in and check "save in keychain":

  ```
  $ echo "test" | gpg --clearsign
  ```

- If pinentry-mac or your GPG agent is not working, go back to the "Configure Pinentry-Mac" section and make sure you're configuration file has that line. You can also do the following again:

  ```
  $ killall gpg-agent
  ```

  The above will most likely solve it, but if not, you can also try starting the agent in daemon mode:

  ```
  $ gpg agent --daemon
  ```

  Maybe try signing the test message again now.

- If commits on the web or on GitHub Desktop aren't being signed:

  - Make sure that, in your [Github account email preferences](https://github.com/settings/emails), "Keep my email addresses private" is _not checked_
  - In GitHub Desktop, go to "GitHub Desktop > Preferences > Git" and check that your email address there matches your GPG key's email address, your primary email address on GitHub, and your user.email info on local git. To see the latter, you can type the following in the terminal:

  ```
  $ git config user.email
  ```

