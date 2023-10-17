#!/bin/bash

read -p "Введите имя файла: " filename
echo -e "Содержимое файла $filename: \n$(cat $filename)"
