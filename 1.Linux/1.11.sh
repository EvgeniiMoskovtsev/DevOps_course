#!/bin/bash

read -p "Введите имя файла: " filename
if [ -f $filaname ]; then
	sed -i 's/error/warning/' $filename
else
	echo "Файл $filename не существует"
fi
