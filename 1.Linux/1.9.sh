#!/bin/bash

read -p "Введите имя файла: " filename
if [ -f $filename ]; then
       	echo -e "Содержимое файла $filename: \n$(cat $filename)"
else 
	echo "Файл $filename не существует"
fi
