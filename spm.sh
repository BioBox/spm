#!/bin/sh
# Copyright (C) 2013-2015 Sören Tempel
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

if [ -z "${PASSWORD_STORE_KEY}" ]; then
	GPG_OPTS="${GPG_OPTS} --default-recipient-self"
else
	GPG_OPTS="${GPG_OPTS} --recipient ${PASSWORD_STORE_KEY}"
fi

## Helper

die() {
	printf '%s\n' "${1}" 1>&2
	exit 1
}

readpw() {
	if [ -t 0 ]; then
		printf '%s' "${1}"
		stty -echo
	fi

	IFS= read -r "${2}"
	[ -t 0 ] && stty echo
}

## Commands

add() {
	[ -z "${1}" ] && die 'Name must not be empty.'
	[ -e "${STORE_DIR}"/"${1}".gpg ] && die 'Entry already exists.'

	readpw "Password for '${1}': " password
	[ -t 0 ] && printf '\n'

	[ -z "${password}" ] && die 'No password specified.'

	mkdir -p "$(dirname "${STORE_DIR}"/"${1}".gpg)"
	printf '%s\n' "${password}" \
		| gpg2 ${GPG_OPTS} --encrypt --output "${STORE_DIR}"/"${1}".gpg
}

list() {
	[ -d "${STORE_DIR}" ] || mkdir -p "${STORE_DIR}"

	[ -n "${1}" ] && [ ! -d "${STORE_DIR}/${1}" ] \
		&& die "No such group. See 'spm list'."

	tree ${grps_only:+-d} --noreport -l -C -- "${STORE_DIR}/${1}" \
		| sed "1s,${STORE_DIR}/,,; s,.gpg,,g"
}

del() {
	[ -z "${1}" ] && die 'Name must not be empty.'
	[ -w "${STORE_DIR}"/"${1}".gpg ] || die 'No such entry.'

	rm -i "${STORE_DIR}"/"${1}".gpg
}

show() {
	[ -z "${1}" ] && die 'Name must not be empty.'

	entry="${STORE_DIR}"/"${1}".gpg

	if [ ! -r "${entry}" ]; then
		entry=$(find "${STORE_DIR}" \( -type f -o -type l \) \
				-iwholename "*${1}*".gpg)

		[ -z "${entry}" ] && die 'No such entry.'

		[ "$(printf '%s' "${entry}" | wc -l)" -gt 0 ] \
			&& die 'Too ambigious keyword.'
	fi

	gpg2 ${GPG_OPTS} --decrypt "${entry}"
}

## Parse input

[ ${#} -eq 0 ] || [ ${#} -gt 3 ] \
|| [ ${#} -eq 3 ] && [ "${1}" != list ] \
	&& die "Invalid number of arguments. See 'spm help'."

case "${1}" in
	add|del|show)
		${1}	"${2}"
		;;
	list)
		[ "${2}" = -g ] && grps_only=1 && shift 1
		list	"${2}"
		;;
	help)
		cat <<- EOF
		USAGE:	spm add|del|list [-g]|show|help [ENTRY|GROUP]

		See spm(1) for more information.
		EOF
		;;
	*)
		die	"Invalid command. See 'spm help'."
		;;
esac
