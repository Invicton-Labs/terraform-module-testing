#!/bin/bash
set -e

lowest_version="0.13.2"
lowest_major=$(echo $lowest_version | cut -d. -f1)
lowest_minor=$(echo $lowest_version | cut -d. -f2)
lowest_patch=$(echo $lowest_version | cut -d. -f3)

versions_html=$(curl -s https://releases.hashicorp.com/terraform/ 2>&1)
version_lines=$(echo "$versions_html" | grep -oE "terraform/[0-9]+\.[0-9]+\.[0-9]+/")

selected_versions=""

while read -r version ; do
    major=$(echo $version | cut -d. -f1)
    minor=$(echo $version | cut -d. -f2)
    patch=$(echo $version | cut -d. -f3)
    if [ $major -gt $lowest_major ] || ( [ $major -eq $lowest_major ] && [ $minor -gt $lowest_minor ] ) || ( [ $major -eq $lowest_major ] && [ $minor -eq $lowest_minor ] && [ $patch -ge $lowest_patch ] ); then
        if [ $patch -eq 0 ] || [ $version = $lowest_version ]; then
            if [ -z $selected_versions ]; then
                selected_versions="$version"
            else
                selected_versions="$selected_versions,$version"
            fi
        fi
    fi
done <<<$(echo "$version_lines" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")

jq -n --arg inarr "${selected_versions}" '$inarr | split(",")'