#!/bin/bash

# FusionInventory Client installation for MacOSX
#

# Copyright © Yorick Barbanneau
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# The Software is provided “as is”, without warranty of any kind, express or
# implied, including but not limited to the warranties of merchantability,
# fitness for a particular purpose and noninfringement. In no event shall the
# authors or copyright holders be liable for any claim, damages or other
# liability, whether in an action of contract, tort or otherwise, arising from,
# out of or in connection with the software or the use or other dealings in the
# Software


FI_INSTALLER_URL=$(curl -s https://github.com/fusioninventory/fusioninventory-agent/releases | awk -F '"' '/href="(https:\/\/.*\.pkg\.tar\.gz)"/{ print $2 }' | head -n 1)
VERSION="1.0"
DEBUG=0
default_tags=""
default_password=""
default_user=""
default_server=""

usage () { 
cat  << EOF 

    MacOS FusionInventory Installer -- Install
    FusionInventory agent on MacOSX

    arg: -s|--server   <server>
    arg: -u|--user     <username>
    arg: -p|--password <password>
    arg: -t|--tag      <tags>

EOF
}

show_version () {
    printf "mac_fusinv-install version %s\n" $VERSION
    exit 0
}
process_args() {
    # While getops doesn't handle long parameters
    # I need an personnal function
    # Inspired by http://mywiki.wooledge.org/BashFAQ/035
    while :; do

        case $1 in
            -d|--debug)
                DEBUG=1
                ;;
            -h|-\?|--help)
                usage
                exit 0
                ;;
            -p|--password)
                password="$2"
                shift
                ;;
            -s|--server)
                server="$2"
                shift
                ;;
            -u|--user)
                user="$2"
                shift
                ;;
            -t|--tag)
                tags="${tags} ${2}"
                shift
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            *)
            break
        esac
        shift
    done
}

error () {
    local message
    message="$*"
    1>&2 printf "ERROR: %s%b%s\n" $'\e[1;31m' "$message" $'\e[0m'
}

warning () {
    local message
    message="$*"
    printf "WARNING: %s%b%s\n" $'\e[1;33m' "$message" $'\e[0m'
}

fatal () {
    local code
    local message
    code="$1"
    shift
    message="$*"
    error "$message"
    exit "$code"
}

debug () {
    local message
    message="$*"
    if (( DEBUG == 1 ))
    then
        printf "DEBUG: %s%b%s\n" $'\e[1;34m' "$message" $'\e[0m'
    fi
}

message () {
    local message="$*" 
    printf "%b\n" "${message}"
}

validate () {
    local message
    message="$*"
    printf "%s%b%s\n" $'\e[1;32m' "$message" $'\e[0m'
}

clean () {
    if [ -n "$tmp_dir" ]
    then
        message "Clean temporary files:"
        debug "Temporary directory to remove: ${tmp_dir}"
        rm -rf "$tmp_dir" || error "Can't clean ${tmp_dir}"
        validate "\t-> Done"
    fi
}


trap clean 0
[[ "$FI_INSTALLER_URL" == "" ]] && fatal 5 "can't grab F.I. installer URL, check your connexion\n" "err"
process_args "$@"

# Check user
[[ "$(whoami)" == "root" ]] || fatal 1 "You must be root (or use sudo) to run this script."

debug "Process variables"
server="${server:=$default_server}"
user="${user:=$default_user}"
password="${password:=$default_password}"
tags="${tags:=$default_tags}"

debug "create temporary directory"
tmp_dir=$(mktemp -d -t fi_installer)
debug "  ->${tmp_dir}"

debug "Installer URL ${FI_INSTALLER_URL}"
message "Downloading installer"
curl -s -L "${FI_INSTALLER_URL}" -o "${tmp_dir}/Installer.tar.gz" > /dev/null || fatal 10 "Error on fusion inventory installer download"
validate "\t-> Installer downloaded"

debug "Extract ${tmp_dir}\Installer.tar.gz"
message "Extract: "
tar -xf "${tmp_dir}/Installer.tar.gz" --directory "$tmp_dir" &> /dev/null || fatal 11 "can't extract"
validate "\t-> Installer extracted"

fi_directory=$(ls -d ${tmp_dir}/*/)
debug "Extracted directory: ${tmp_dir}"
conf_file="${fi_directory}Contents/Resources/agent.cfg"
debug "Agent configuration file to process : ${conf_file}"

message "Process Fusion inventory configuration file:"
message "\t-> Remove comments and blank lines"
sed -i '' '/^#/ d' "${conf_file}" &> /dev/null || warning "Can't remove comment lines"
sed -i '' '/^$/ d' "${conf_file}" &> /dev/null|| warning "Can't remove blank lines"
validate "\t-> Removed"

message "Configure server with ${server}:"
sed -i '' '1i\
server = 
' "${conf_file}" &> /dev/null || fatal 20 "Can't insert server variable in configuration"  
sed -E -i '' "s|^(server\ =).*|\1 ${server}|g" "${conf_file}" || fatal 21 "Can't add current server in configuration file"
validate "\t-> Configured"

message "Put username and password for proxy"
sed -E -i '' "s/^(user\ =).*/\1 ${user}/g" "${conf_file}" || fatal 30 "Can't add username in configuration file"
sed -E -i '' "s/^(password\ =).*/\1 ${password}/g" "${conf_file}" || fatal 31 "Can't add password in configuration file"
validate "\t-> Username and pass added"

message "Put tags in configuration file:"
debug "Tags to add: ${tags}"
sed -E -i '' "s/^(tag\ =).*/\1 ${tags}/g" "${conf_file}" || warning "Can't add tags in configuration file"
validate "\t-> Tags added"

message "Install Fusion Inventory Package: "
debug "Package to install: ${fi_directory}" 
installer -pkg "${fi_directory}" -target / &>/dev/null || fatal 50 "Can't install package"
validate "\t-> Installed"
exit 0
