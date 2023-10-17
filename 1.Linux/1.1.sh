#!/bin/bash

if [[ $USER == "root" ]]; then
	echo "root user"
else
	echo "$USER user"
fi
