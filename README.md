spm - simple password manager
=============================

spm is a single fully POSIX shell compliant script utilizing gpg2(1) in
combination with basic tools such as find(1) and tree(1).

spm stores everything in a directory structure where passwords correspond to
individually [PGP](https://gnupg.org/) encrypted files, optionally residing inside nested
subdirectories of arbitrary depth, where any subdirectory can be interpreted
as a (sub)group to manage large collections easily.

This project started as a fork of mneum's [tpm](https://github.com/nmeum/tpm) which at that time was lacking
crucial features such as removing or listing existent entries (it still does).

spm works perfectly with standard input and output allowing easy integration
with other tools to create a truely flexible and powerful password management
tool.

Refer to the manual page for various examples or simply read its source code.

---

*.sh/spm* from my [dotfiles](https://notabug.org/kl3/dotfiles) repository also illustrates an easy way to integrate
spm.
