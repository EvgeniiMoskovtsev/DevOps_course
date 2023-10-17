#!/bin/bash

read -p "Введите имя каталога: " foldername
echo -e "Файлы в каталоге $foldername: \n$(ls $foldername)"
