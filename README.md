# Secure Development Setup for macOS

### ***by [Christopher Allen]((https://github.com/ChristopherA)), [Shannon Appelcline](https://github.com/shannona), and [Namcios](https://github.com/namcios)***

This repo offers documentation and scripts for setting up git, github, gpg and ssh on a new Mac computer.

## Additional Information

At this time these documents and scripts are focused on installation of a secure developer tool environment for a macOS Big Sur 11.5 on an Intel Mac computer.

In particular, the scripts in this repo are being tested using a VMware Fusion instance to allow for use of snapshots and restoration, and thus they have not been tested against real Macintosh hardware at this time. They are intended for use on a NEW Macintosh, and may destroy or compromise your development environment on an existing Macintosh.

>  NOTE: Compatibility with M1 Macs (Apple Silicon) is not currently ensured.

### Index

The documentation provided in this repo explains how to work on the command line and how to create an open-source development environment on your Mac.

The scripts automate what is suggested in the documentation. However, it might help to have the documentation open since some of the steps will be interactive. Having the docs open while you run the scripts will allow you to choose the best options when prompted for inputs. The scripts also print some hints to the console as to what you should select and when.

- Documentation
  - [Mac Command Line 101](https://github.com/BlockchainCommons/Secure-Development-Setup-macOS/tree/master/Mac%20Command%20Line%20101) provides an introductory guide for learning about the command line interface on a Mac, assuming no previous knowledge.
    - [Part 1 - Basics](https://github.com/BlockchainCommons/Secure-Development-Setup-macOS/blob/master/Mac%20Command%20Line%20101/part1-basics.md) goes over the basic concepts of working with the command line and get familiarized with it.
    - [Part 2 - Prepare](https://github.com/BlockchainCommons/Secure-Development-Setup-macOS/blob/master/Mac%20Command%20Line%20101/part2-prepare.md) outlines the creation a development environment on your Mac, as well as some tools you might want if you don't intend to use the command line for everyday tasks.
  - [GPG with GitHub](gpg-with-github.md) walks through the creation process of a new GPG keypair and the steps necessary to configure GitHub to use your new GPG keypair for commit signing.
- Scripts
  - [initial-macos-developer-setup.sh](initial-macos-developer-setup.sh) installs core development dependencies on your Mac, including updates, Xcode Command Line Tools and brew, tapping essential sources, and checking for necessary updates.
  - [additional-setup.sh](additional-setup.sh) installs extra tools for your development needs if they're not already installed, including git, GitHub CLI, GnuPG (as well as create new GPG keys, configure gpg and pinentry-mac, create a revocation certificate, configure git to allow GPG signed commits), GitHub Desktop, and a text editor/code IDE of your choice.

## Status - EARLY DRAFT

This contents of this repo are currently under active development but are only in EARLY DRAFT stage. It should not be used for production tasks until it has had further testing and auditing.

### Roadmap

July 2021
- Completion of documentation

August 2021
- Completion of scripts

## Origin, Authors, Copyright & Licenses

Unless otherwise noted (either in this [/README.md](./README.md) or in a file's header comments) the contents of this repository are Copyright © 2020 by Blockchain Commons, LLC, and are [licensed](./LICENSE) under the [spdx:BSD-2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html).

In most cases, the authors, copyright, and license for each file reside in header comments in the source code. When it does not, we have attempted to attribute it accurately in the table below.

This table below also establishes provenance (repository of origin, permalink, and commit id) for files included from repositories that are outside of this repo. Contributors to these files are listed in the commit history for each repository, first with changes found in the commit history of this repo, then in changes in the commit history of their repo of their origin.

| File      | From                                                         | Commit                                                       | Authors & Copyright (c)                                | License                                                     |
| --------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------ | ----------------------------------------------------------- |
| exception-to-the-rule.c or exception-folder | [https://github.com/community/repo-name/PERMALINK](https://github.com/community/repo-name/PERMALINK) | [https://github.com/community/repo-name/commit/COMMITHASH]() | 2020 Exception Author  | [MIT](https://spdx.org/licenses/MIT)                        |

### Dependencies

None

### Libraries

The following external libraries are used with `$projectname`:

- [community/repo-name](https://github.com/community/repo-name) — What the library does (use OR fork [version] OR include [version]).

Libraries may be marked as `use` (the current version of the library is used), `fork` (a specific version has been forked to the BCC repos for usage), or `include` (files from a specific version have been included).

### Derived from…

This project is either derived from or was inspired by:

- [prepare-osx-for-webdev](https://github.com/ChristopherA/prepare-osx-for-webdev) — Script to prepare a Mac computer for web development and command-line tools, by [Christopher Allen](https://github.com/ChristopherA).

- [intro-mac-command-line](https://github.com/ChristopherA/intro-mac-command-line) — An introduction to the Mac Command Line, by [Christopher Allen](https://github.com/ChristopherA).

## Subsequent Usage

### Adapted by...

These are adaptations, conversions, and wrappers that make `$projectname` available for other languages:

- [community/repo-name/](https://github.com/community/repo-name) — Repo that does what, by [developer](https://github.com/developer)  or from  [community](https://community.com)(language).


### Used with...

These are other projects that work with or leverage `$projectname`:

- [community/repo-name/](https://github.com/community/repo-name) — Repo that does what, by [developer](https://github.com/developer)  or from  [community](https://community.com).

## Financial Support

*Secure Development Setup* is a project of [Blockchain Commons](https://www.blockchaincommons.com/). We are proudly a "not-for-profit" social benefit corporation committed to open source & open development. Our work is funded entirely by donations and collaborative partnerships with people like you. Every contribution will be spent on building open tools, technologies, and techniques that sustain and advance blockchain and internet security infrastructure and promote an open web.

To financially support further development of *Secure Development Setup* and other projects, please consider becoming a Patron of Blockchain Commons through ongoing monthly patronage as a [GitHub Sponsor](https://github.com/sponsors/BlockchainCommons). You can also support Blockchain Commons with bitcoins at our [BTCPay Server](https://btcpay.blockchaincommons.com/).

## Contributing

We encourage public contributions through issues and pull requests! Please review [CONTRIBUTING.md](./CONTRIBUTING.md) for details on our development process. All contributions to this repository require a GPG signed [Contributor License Agreement](./CLA.md).

### Discussions

The best place to talk about Blockchain Commons and its projects is in our GitHub Discussions areas.

[**Gordian System Discussions**](https://github.com/BlockchainCommons/Gordian/discussions). For users and developers of the Gordian system, including the Gordian Server, Bitcoin Standup technology, QuickConnect, and the Gordian Wallet. If you want to talk about our linked full-node and wallet technology, suggest new additions to our Bitcoin Standup standards, or discuss the implementation our standalone wallet, the Discussions area of the [main Gordian repo](https://github.com/BlockchainCommons/Gordian) is the place.

[**Wallet Standard Discussions**](https://github.com/BlockchainCommons/AirgappedSigning/discussions). For standards and open-source developers who want to talk about wallet standards, please use the Discussions area of the [Airgapped Signing repo](https://github.com/BlockchainCommons/AirgappedSigning). This is where you can talk about projects like our [LetheKit](https://github.com/BlockchainCommons/bc-lethekit) and command line tools such as [seedtool](https://github.com/BlockchainCommons/bc-seedtool-cli), both of which are intended to testbed wallet technologies, plus the libraries that we've built to support your own deployment of wallet technology such as [bc-bip39](https://github.com/BlockchainCommons/bc-bip39), [bc-slip39](https://github.com/BlockchainCommons/bc-slip39), [bc-shamir](https://github.com/BlockchainCommons/bc-shamir), [Sharded Secret Key Reconstruction](https://github.com/BlockchainCommons/bc-sskr), [bc-ur](https://github.com/BlockchainCommons/bc-ur), and the [bc-crypto-base](https://github.com/BlockchainCommons/bc-crypto-base). If it's a wallet-focused technology or a more general discussion of wallet standards,discuss it here.

[**Blockchain Commons Discussions**](https://github.com/BlockchainCommons/Community/discussions). For developers, interns, and patrons of Blockchain Commons, please use the discussions area of the [Community repo](https://github.com/BlockchainCommons/Community) to talk about general Blockchain Commons issues, the intern program, or topics other than the [Gordian System](https://github.com/BlockchainCommons/Gordian/discussions) or the [wallet standards](https://github.com/BlockchainCommons/AirgappedSigning/discussions), each of which have their own discussion areas.

### Other Questions & Problems

As an open-source, open-development community, Blockchain Commons does not have the resources to provide direct support of our projects. Please consider the discussions area as a locale where you might get answers to questions. Alternatively, please use this repository's [issues](./issues) feature. Unfortunately, we can not make any promises on response time.

If your company requires support to use our projects, please feel free to contact us directly about options. We may be able to offer you a contract for support from one of our contributors, or we might be able to point you to another entity who can offer the contractual support that you need.


### Credits

The following people directly contributed to this repository. You can add your name here by getting involved. The first step is learning how to contribute from our [CONTRIBUTING.md](./CONTRIBUTING.md) documentation.

| Name              | Role                    | Github                                           | Email                                 | GPG Fingerprint                                    |
| ----------------- | ----------------------- | ------------------------------------------------ | ------------------------------------- | -------------------------------------------------- |
| Christopher Allen | Principal Architect     | [@ChristopherA](https://github.com/ChristopherA) | \<ChristopherA@LifeWithAlacrity.com\> | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED |
| Namcios           | Developer and Co-Author | [@namcios](https://github.com/namcios)           | \<namcios@protonmail.com\>            | 55A2 4BE0 AEE5 DB41 52C6 A410 8E3A 3683 1726 9AB4  |

## Responsible Disclosure

We want to keep all of our software safe for everyone. If you have discovered a security vulnerability, we appreciate your help in disclosing it to us in a responsible manner. We are unfortunately not able to offer bug bounties at this time.

We do ask that you offer us good faith and use best efforts not to leak information or harm any user, their data, or our developer community. Please give us a reasonable amount of time to fix the issue before you publish it. Do not defraud our users or us in the process of discovery. We promise not to bring legal action against researchers who point out a problem provided they do their best to follow the these guidelines.

### Reporting a Vulnerability

Please report suspected security vulnerabilities in private via email to ChristopherA@BlockchainCommons.com (do not use this email for support). Please do NOT create publicly viewable issues for suspected security vulnerabilities.

The following keys may be used to communicate sensitive information to developers:

| Name              | Fingerprint                                        |
| ----------------- | -------------------------------------------------- |
| Christopher Allen | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED |

You can import a key by running the following command with that individual’s fingerprint: `gpg --recv-keys "<fingerprint>"` Ensure that you put quotes around fingerprints that contain spaces.
