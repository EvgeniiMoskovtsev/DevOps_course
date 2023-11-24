#!/bin/bash

read -p "Введите имя каталога: " foldername

if [ -d $foldername ]; then
	echo -e "Файлы в каталоге $foldername: \n$(ls $foldername)"
else
	echo "Каталог $foldername не найден"
fi
