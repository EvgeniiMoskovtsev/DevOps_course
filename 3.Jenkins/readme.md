Для работы с Jenkins я буду использовать AWS EC2,
сам Jenkins будет работать из докера

Для установки я воспользовался официальной документацией
https://www.jenkins.io/doc/book/installing/docker/

Запустил докер образ на 8080 (как в документации) и открыл этот порт в
security group на AWS

Приложение буду использовать из задания 2.4

Free tier server t3.micro умер, поэтому пришлось заново накатывать все на более мощный

Взял medium сервер. Pipeline завелся, но выдает ошибку
Installing collected packages: zipp, MarkupSafe, itsdangerous, click, blinker, Werkzeug, Jinja2, importlib-metadata, flask
ERROR: Could not install packages due to an OSError: [Errno 13] Permission denied: '/.local'
Check the permissions.

Добавив args '-u root' в agent docker проблема решилась

