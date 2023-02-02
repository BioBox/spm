spm - simple password manager
=============================

spm is a single fully POSIX shell compliant script that acts as a central
password manager.

Passwords are stored as [age][age] encrypted files with
directories funtioning as (sub)groups. It actually uses [rage][rage], but you
can use a sed(1) substitude command to make it use the go implementation if you
wish.

spm reads/writes passwords via standard input/output allowing you to build
flexible and powerful management tools. [pwgen][pwgen] is a very good
supplimentary tool.

Refer to the manual page for various examples or read its source code to see
how it works.

This Fork aims to make it more suckless and POSIX compliant, which is why age
is preferred over gpg.

----

spm started as [tpm][tpm] fork.

[age]: https://github.com/FiloSottile/age
[rage]: https://github.com/str4d/rage
[pwgen]: https://github.com/jbernard/pwgen
[tpm]: https://github.com/nmeum/tpm
