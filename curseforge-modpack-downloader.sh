#!/bin/sh

# Copyright 2015-2021 Rivoreo
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if [ $# -lt 1 ]; then
	echo "Usage: curseforge-modpack-downloader manifest.json"
	exit 1
fi

# checking if jq(1) exist
if ! command -v jq > /dev/null 2>&1; then
	printf "jq is not detected\\n"
	exit
fi
# checking if wget exist
if ! command -v wget > /dev/null 2>&1; then
	printf "wget is not detected\\n"
	exit
fi

# creating mods/ directory
mkdir -p mods

MODS_AMOUNT="`jq '.files|length' \"$1\"`"
echo "There are $MODS_AMOUNT mods in total."

i=0
while [ $i -lt $MODS_AMOUNT ]; do
	if [ "`jq \".files[$i].required\" \"$1\"`" = "true" ]; then
		projectID="`jq \".files[$i].projectID\" \"$1\"`"
		fileID="`jq \".files[$i].fileID\" \"$1\"`"
		API_RESULT="`wget --quiet -O - \"https://addons-ecs.forgesvc.net/api/v2/addon/$projectID/file/$fileID\"`"
		MOD_URL="`printf %s "$API_RESULT" | jq --raw-output .downloadUrl`"
		MOD_NAME="`printf %s "$API_RESULT" | jq --raw-output .displayName`"
		printf %s\\n "Downloading $MOD_NAME ... $((MODS_AMOUNT-i-1)) mods remaining ..."
		wget --show-progress --no-clobber --directory-prefix mods/ "$MOD_URL"
# curseforge reject --continue. since we can't continue download a file, may be we should skip any existing file (assuming they are complete)
	fi
	i=$((i+1))
done
