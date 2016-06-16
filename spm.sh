#!/bin/sh
# Copyright (C) 2013-2016 Sören Tempel
# Copyright (C) 2016 Klemens Nanni <kl3@posteo.org>
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

umask 077

## Variables

GPG_OPTS='--quiet --yes --batch'
STORE_DIR="${PASSWORD_STORE_DIR:-${HOME}/.spm}"

## Helper

die() {
	printf 'Error: %s.\n' "${1}" 1>&2
	exit 1
}

check() {
	[ -z "${entry}" ] && die 'No such entry'

	[ "$(printf '%s' "${entry}" | wc -l)" -gt 0 ] \
		&& die "Too ambigious keyword. Try 'spm search'"
}

gpg() {
	[ -z "${PASSWORD_STORE_KEY}" ] \
		&& gpg2 ${GPG_OPTS} --default-recipient-self "${@}" \
		|| gpg2 ${GPG_OPTS} --recipient "${PASSWORD_STORE_KEY}" "${@}"
}

readpw() {
	[ -t 0 ] && stty -echo && printf '%s' "${1}"
	IFS= read -r "${2}"
	[ -z "${2}" ] && die 'No password specified'
}

_search() {
	find "${STORE_DIR}"/ \( -type f -o -type l \) \
		-iwholename "*${1}*".gpg
}

view() {
	sed s/.gpg//g | less -E -i -K -R -X
}

## Commands

add() {
	[ -e "${STORE_DIR}"/"${1}".gpg ] && die 'Entry already exists'

	readpw "Password for '${1}': " password
	[ -t 0 ] && printf '\n'

	mkdir -p "${STORE_DIR}"/"${1%/*}"/
	printf '%s\n' "${password}" \
		| gpg --encrypt --output "${STORE_DIR}"/"${1}".gpg
}

list() {
	[ -d "${STORE_DIR}"/"${1:-}" ] || die "No such group. See 'spm list'"

	tree ${grps_only:+-d} --noreport -l --dirsfirst --sort=name -C \
			-- "${STORE_DIR}"/"${1:-}" \
		| view
}

del() {
	entry=$(_search "${1}" | head -n2)
	check
	rm -i "${entry}"; printf '\n'
}

search() {
	_search "${1}" \
		| view
}

show() {
	entry=$(_search "${1}" | head -n2)
	check
	gpg --decrypt "${entry}"
}

## Parse input

[ ${#} -eq 0 ] || [ ${#} -gt 3 ] \
|| [ ${#} -eq 3 ] && [ "${1}" != list ] \
	&& die "Invalid number of arguments. See 'spm help'"

case "${1}" in
	add|del|search|show)
		[ -z "${2}" ] && die 'Name must not be empty'
		${1}	"${2}"
		;;
	list)
		[ "${2}" = -g ] && grps_only=1 && shift 1
		list	"${2}"
		;;
	help)
		cat <<- EOF
		USAGE:	spm add|del|list [-g]|search|show|help [ENTRY|GROUP]

		See spm(1) for more information.
		EOF
		;;
	*)
		die	"Invalid command. See 'spm help'"
		;;
esac
