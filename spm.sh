#!/bin/sh
# Copyright (C) 2013-2016 Sören Tempel
# Copyright (C) 2016, 2017 Klemens Nanni <kl3@posteo.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

set -eu
umask 077

## Variables
GPG_OPTS='--quiet --yes --batch'
STORE_DIR="${PASSWORD_STORE_DIR:-${HOME}/.spm}"

## Helper
usage() {
	cat 1>&2 <<-EOF
	${1:+Error: ${1}}
	USAGE: ${0##*/} add|del|list [-g]|search|show|help [[group/]name|expression]
	See spm(1) for more information.
	EOF

	exit ${1:+1}
}

check() {
	[ $(printf '%s' "${entry}" | wc -l) -eq 0 ] ||
		usage 'ambigious expression'

	[ -n "${entry}" ] || usage 'no such entry'
}

gpg() {
	if [ -z "${PASSWORD_STORE_KEY}" ]; then
		gpg2 ${GPG_OPTS} --default-recipient-self "${@}"
	else
		gpg2 ${GPG_OPTS} --recipient "${PASSWORD_STORE_KEY}" "${@}"
	fi
}

readpw() {
	[ -t 0 ] && stty -echo && printf '%s' "${1}"
	IFS= read -r "${2}"
	[ -z "${2}" ] && usage 'empty password'
}

find() {
	command find "${STORE_DIR}" \( -type f -o -type l \) |
		grep -Gie "${1}"
}

view() {
	less -EiKRX
}

## Commands
add() {
	[ -e "${STORE_DIR}"/"${1}" ] && usage 'entry already exists'

	password=
	readpw "Password for '${1}': " password
	[ -t 0 ] && printf '\n'

	group="${1%/*}"
	[ "${group}" = "${1}" ] && group=

	mkdir -p "${STORE_DIR}"/"${group}" &&
		printf '%s\n' "${password}" |
			gpg --encrypt --output "${STORE_DIR}"/"${1}"
}

list() {
	[ -d "${STORE_DIR}"/"${1:-}" ] || usage 'no such group'

	tree ${gflag:+-d} -Fx -- "${STORE_DIR}"/"${1:-}" | view
}

del() {
	entry=$(find "${1}" | head -n2)
	check; rm -i "${entry}" && printf '\n'
}

search() {
	find "${1}" | view
}

show() {
	entry=$(find "${1}" | head -n2)
	check; gpg --decrypt "${entry}"
}

## Parse input
[ ${#} -eq 0 ] || [ ${#} -gt 3 ] ||
[ ${#} -eq 3 ] && [ "${1:-}" != list ] &&
	usage 'wrong number of arguments'

case "${1}" in
	add|del|search|show)
		[ -z "${2:-}" ] && usage 'empty name'
		${1} "${2}"
		;;
	list)
		if [ "${2:-}" = -g ] && [ ${#} -le 3 ]; then
			gflag=1; shift 1
		elif [ ${#} -gt 2 ]; then
			usage 'too many arguments'
		fi
		list "${2:-}"
		;;
	help)
		usage
		;;
	*)
		usage 'invalid command'
		;;
esac
