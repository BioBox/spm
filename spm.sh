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

usage() {
	cat 1>&2 <<-EOF
	${1:+Error:	${1}}
	USAGE:	spm add|del|list [-g]|search|show|help [ENTRY|GROUP]
	See spm(1) for more information.
	EOF

	exit ${1:+1}
}

check() {
	[ -z "${entry}" ] && usage 'No such entry'

	[ "$(printf '%s' "${entry}" | wc -l)" -gt 0 ] \
		&& usage "Ambigious keyword. Try 'spm search'"
}

gpg() {
	[ -z "${PASSWORD_STORE_KEY}" ] \
		&& gpg2 ${GPG_OPTS} --default-recipient-self "${@}" \
		|| gpg2 ${GPG_OPTS} --recipient "${PASSWORD_STORE_KEY}" "${@}"
}

readpw() {
	[ -t 0 ] && stty -echo && printf '%s' "${1}"
	IFS= read -r "${2}"
	[ -z "${2}" ] && usage 'Empty password'
}

_find() {
	find "${STORE_DIR}"/ \( -type f -o -type l \) -iwholename "*${1}*".gpg \
		-printf "${2:-%p\n}"
}

view() {
	sed -e s/.gpg//g | less -E -i -K -R -X
}

## Commands

add() {
	[ -e "${STORE_DIR}"/"${1}".gpg ] && usage 'Entry already exists'

	readpw "Password for '${1}': " password
	[ -t 0 ] && printf '\n'

	group="${1%/*}"
	[ "${group}" = "${1}" ] && group=

	mkdir -p "${STORE_DIR}"/"${group}"/
	printf '%s\n' "${password}" \
		| gpg --encrypt --output "${STORE_DIR}"/"${1}".gpg
}

list() {
	[ -d "${STORE_DIR}"/"${1:-}" ] || usage "No such group. See 'spm list'"

	tree ${groups_only:+-d} --noreport -l --dirsfirst --sort=name -C \
			-- "${STORE_DIR}"/"${1:-}" \
		| view
}

del() {
	entry=$(_find "${1}" | head -n2)
	check
	rm -i "${entry}"; printf '\n'
}

search() {
	_find "${1}" '%P\n' \
		| view
}

show() {
	entry=$(_find "${1}" | head -n2)
	check
	gpg --decrypt "${entry}"
}

## Parse input

[ ${#} -eq 0 ] || [ ${#} -gt 3 ] \
|| [ ${#} -eq 3 -a "${1}" != list ] \
	&& usage 'Wrong number of arguments'

case "${1}" in
	add|del|search|show)
		[ -z "${2}" ] && usage 'Empty name'
		${1}	"${2}"
		;;
	list)
		if [ "${2}" = -g ] && [ ${#} -le 3 ]; then
			groups_only=1 && shift 1
		elif [ ${#} -gt 3 ]; then
			usage 'Wrong number of arguments'
		fi
		list	"${2}"
		;;
	help)
		usage
		;;
	*)
		usage	'Invalid command'
		;;
esac
