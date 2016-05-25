spm - simple password manager
=============================

This is a fork of [nmeum's tpm](https://github.com/nmeum/tpm), I felt like changing things here and there
was necessary to finally get the password manager that suits my needs.

From the original project:

> tpm is a tiny shell script which is heavily inspired and largely compatible
> with [pass](http://zx2c4.com/projects/password-store). Just like pass it uses gpg2(1) to securely store your passwords,
> the major difference between pass and tpm is that the latter is a lot more
> minimal. Furthermore, tpm is written entirely in POSIX shell.

---

Create a new entry with a random password using `pwgen`:

	$ pwgen -1 | spm add system/new-user

Create a new entry called *system/root*:

	$ spm add system/root

Write your *system/root* password to standard output:

	$ spm show system/root

Write the entry's password that matches the given pattern to standard output:

	$ spm show em/r*t
	$ spm show sys*ot
	$ spm show root

Copy your *system/root* password to the primary selection using `xclip`:

	$ spm show system/root | tr -d '\n' | xclip

List all entries of the group *system*:

	$ spm list system

---

Also see my aliases in *.sh/spm* from my [dotfiles](https://notabug.org/kl3/dotfiles) repository for other
examples on how to make spm even easier to use.
