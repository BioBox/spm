spm - simple password manager
=============================

spm is a single fully POSIX shell compliant script utilizing [GnuPG](https://gnupg.org/) in
combination with the most basic tools only such as find(1) and tree(1).

Passwords as saved as individually encrypted files inside a directory structure
of arbitrary depth. Directory and file names represent group and entry names
respectively.

This project started as a fork of mneum's [tpm](https://github.com/nmeum/tpm) which at that time was lacking
crucial features such as removing or listing existent entries (it still does).

spm works perfectly with standard input and output allowing easy integration
with other tools to create a truely flexible and powerful password management
tool.

Refer to the manual page for various examples or simply read its source code.

---

*.sh/spm* from my [dotfiles](https://notabug.org/kl3/dotfiles) repository also illustrates an easy way to integrate
spm.
