Для работы с TeamCity я буду использовать AWS EC2.
Установка очень простая:

Скачем Java 17:
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm

и установим
sudo yum -y install ./jdk-17_linux-x64_bin.rpm

Скачаем TeamCity:
wget https://download.jetbrains.com/teamcity/TeamCity-2023.05.4.tar.gz

распакуем:
tar -zxvf ./TeamCity-2023.05.4.tar.gz

и запустим:
./TeamCity-2023.05.4.tar.gz/bin/runAll.sh start

Установим Докер, т.к. проект билдится в нем
sudo yum install docker
И добавим в докер груп
sudo usermod -a -G docker ec2-user


TeamCity работает по дефолту на порту 8111, я его открою в SecurityGroups


Создаём проект и указываем репозиторий имя и токен. Создаём stage Build. Далее укаываем Имя билда и ветку (staging)
Выбираем билдить Dockerfile с тэгом %env.BUILD_NUMBER%, чтобы иметь версии билдов. Добавил также билд аргумент:
--build-arg BUILD_EXECUTABLE=ON.

Создадим бэкап. Для этого после каждого билда деплоим проект в dockerhub. 


Теперь деплой. Создадим connection к AWS, укажим access key, secret key, проверим connection:
Running STS get-caller-identity...
Caller Identity:
 Account ID: 779246747823
 User ID: AIDA3K3VZYCXSWXYHPATT
 ARN: arn:aws:iam::779246747823:user/evgenii-admin
 
 Вернул нас, все ок.

И теперь по ssh делаем docker run "наш проект":номер_билда
 
И наконец ставим VCS trigger на Trigger a build on each check in

Тоже самое повторяем для master ветки, только тэг добавим latest и тригер делаем на Pull Requests, для этого в Builder features настраиваем taraget branch: master

