# GPG Signing GitHub Commits

GitHub allows you to use GPG to sign commits. You can use an existing GPG key or generate a new one.

You can find GitHub's official documentation about GPG commit signature verification [here](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/about-commit-signature-verification#gpg-commit-signature-verification). And here's a [GPG cheatsheet](http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/).

:warning: Before starting, make sure you have GPG command line tools installed on your machine and update it if it's outdated already. If you need to or would rather download and install it fresh, head over to [GnuPG's official download page](https://www.gnupg.org/download/) and install the _latest version_ of GPG for your operating system.

:warning: Also make sure you have already [verified your GitHub email](https://docs.github.com/en/articles/verifying-your-email-address) and [set your commit email address](https://docs.github.com/en/articles/setting-your-commit-email-address).

Now we can begin. But you might first check if you already have a GPG key in your machine. If you're sure you don't already have any, skip to "Associating an Email Address With Your GPG Key."

## Check for Existing GPG Keys

To check if you already have any GPG keys, open the Terminal and type:
```
$ gpg --list-secret-keys --keyid-format=long
```

If there's at least one existing GPG key pair shown and you'd like to use that on GitHub, go to the step "Already Have a GPG Key? Import It."

If the command outputs no GPG keys, move on to the next step.

Tip: make sure to use _the same_ key pair for _all_ of the steps below.

## Don't Have a GPG Key? Create One

Again, make sure you have the latest version of GPG for your operating system installed in your machine.

1. Open Terminal
2. Paste the command `gpg --full-generate-key` to generate a key pair
3. Press `Enter` to accept the default key type, or specify the specific kind of key that you want (if you know what you're doing).
4. Press `Enter` again to accept the default key size, or specify the one you want. Here, it must be at least `4096` bits.
5. Now, it is asking for how long should the key be valid. If you press `Enter` and accept the default, your keys will never expire. Specify a desired length of time otherwise.
6. Verify your selections for errors, see if they're correct.
7. Enter your user ID information
8. Choose a secure passphrase. This serves _kind of_ like a password for using your GPG key pair. So make sure you don't forget it.

### [Optional] Generate a Revocation Certificate

Although optional, creating a revocation certificate is very useful. It guards you against and prepares you for the undesired scenario of forgetting your passphrase or losing your private key.

If that happens, you can publish your revocation certificate (for instance, in your website your GitHub profile) and let others know that your now defunct keys should no longer be used. For example, it will warn others that your public key should not be used for encrypting a message or document anymore.

However, even after publishing your revocation certificate, others will still be able to verify signatures made by you in the past using your revoked public key. And you will still also be able to decrypt messages and documents sent to you in the past if you still have access to your private key related to your revoked public key.

To generate the revocation certificate, you will need either "Your Name", email, or KEY_ID. So open up a Terminal window and type one of the following, depending on the info you choose to feed the command with:

```
$ gpg --output revoke.asc --gen-revoke "Your Name"
```
OR
```
$ gpg --output revoke.asc --gen-revoke your.email@example.com
```
OR
```
$ gpg --output revoke.asc --gen-revoke KeyID
```
If you can't remember, you can grab your KeyID with the command `gpg --list-secret-keys --keyid-format=long`. It will be next to `sec`, right after the key type you have, for example `rsa2048/<your-key-id>`.

You might be asked the reason for creating the revocation certificate. You can just type 0 for "no reason specified" and then, if you like, enter some description. Then you can confirm it and your revocation certificate will be generated.

## Associating an Email Address With Your GPG Key

In this section, you will be associating an email account with your selected GPG key. This is important for some reasons, but for this guide's purpose _it allows GitHub to check if your GitHub account's verified email address matches both your committer identity and the email address associated with your GPG key_.

1. Grab the GPG key ID from the key pair which you created or selected in the previous steps.

    To grab it again, type the following in a Terminal window:

    ```
    $ gpg --list-secret-keys --keyid-format=long
    ```

    The console output should be similar to:

    ![](https://i.imgur.com/pyl8oST.png)
    
    Note that in this case the key is already linked to an email address in the user ID (`uid`). If yours is already linked too, and it matches your commit email address, you don't need to do it again. Just skip to step #7 of this section. Keep following along otherwise.

2. Now you have to copy the info you need, which is, in the screenshot above, the string after the first `rsa2048/`.

    In this case, the GPG key ID is `8E3A368317269AB4`.

3. On the Terminal, type the command `gpg --edit-key GPG_KEY_ID`, substituting `GPG_KEY_ID` with your own key ID. In this example, the command would be:

    `$ gpg --edit-key 8E3A368317269AB4`

4. To edit your user ID information, type:

    `$ gpg> adduid`
    
    This assumes your GPG key does not yet have an user ID associated with it.
    
    It will prompt and ask for your name, email address, and other comments. You can modify your entries by choosing `N`, `C`, or `E`.
    
    :warning: Make sure you're using the same email in your GPG key and your GitHub account. GitHub will check and see if they match when you try signing commits with your GPG key. You might need to check or [set your commit email address](https://docs.github.com/en/articles/setting-your-commit-email-address) if you haven't already.
    
    Confirm your selections by entering `O`.

5. Enter your key's passphrase, if it has one.
6. Enter `gpg> save` to save your changes.
7. Now you need to export your GPG key, so you can later add it to your GitHub account. Type the following on a Terminal:

    ```
    $ gpg --armor --export GPG key ID
    ```
    
    The command will print your GPG key in ASCII armor format. Copy that and go on to adding it to your account!

## Adding Your GPG Key to Your GitHub Account

Make sure you have already selected your GPG key pair before moving forward to add it to your GitHub account!

Follow these steps:

1. Log into your GitHub account, navigate to the upper-right hand corner to click your profile photo, then click **Settings**

    ![](https://i.imgur.com/WgLgUf2.png)

2. In the **Account Settings** left sidebar, scroll down a bit and click **SSH and GPG Keys**

    ![](https://i.imgur.com/6MPcLxS.png)

3. Click the green **New GPG key** button on the **GPG Keys** section

    ![](https://i.imgur.com/zTyZB6t.png)

4. In the "Key" field, paste the GPG key you copied on the last section. Make sure you paste the correct public key block, which, as the field reads, begins with `----BEGIN PGP PUBLIC KEY BLOCK----`.

    ![](https://i.imgur.com/i9mUwQr.png)

5. Click the green **Add GPG key** button. It will then prompt and ask for your GitHub password to confirm the action.

Now go on and tell Git about your fresh new key!

## Telling Git About Your GPG Signing Key

To sign commits locally, you need to tell Git what GPG key you would like to use.

1. Again, we are going to start with `gpg --list-secret-keys --keyid-format=long` to pull our key. The command will list the GPG keys for which you have a public/private key pair. The private key is what is going to be used to sign commits or tags.
2. Similarly to the previous section, you copy the long form of the GPG key ID for the key you'd like to use. This will be next to in the `sec` line, next to the key type (for example `rsa2048/<your-key-id>`).
3. Having copied that, you now need to set your GPG signing key for Git. Paste the command below, substituting `<your-key-id>` for your key ID:
    ```
    $ git config --global user.signingkey <your-key-id>
    ```
    Note that the above command will set that key as your signing key for all repositories. This is usually what you'd want, but if you want to set it only for a specific repository: navigate to that repository and remove the `--global` flag.

## Signing Commits

There are some different scenarios as to how you can sign commits.

You can either sign an individual commit; tell Git you want all future commits in the repo you're in to be automatically signed; or set commit signing as default for all repos in your account.

Note that your passphrase might be asked! If so, just type it in and hit `Enter`.

To sign individual commits:
```
$ git commit -S -m "commit message"
```

To sign all commits by default in current repo:
```
$ git config commit.gpgsign true
```

To sign all commits by default in all repos:
```
$ git config --global commit.gpgsign true
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