#!/usr/bin/env bash

# Find "Last modified: yyyy-mm-dd" in index.gmi and update to today's date
timestamp=`date +"%Y-%m-%d"`
sed -i "s/Last modified: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/Last modified: $timestamp/g" index.gmi

# Git update
git add . && git commit -a -m "Update content" && git push origin master && git push raspberrypi master
