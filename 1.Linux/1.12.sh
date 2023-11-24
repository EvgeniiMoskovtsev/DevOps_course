#!/bin/bash

dir="/var/log"
files=$( grep -rl "error" $dir 2>/dev/null)
if [ -n "$files" ]; then
	echo "$files"
else
	echo "Файлов с error нет"
fi
