Часть 1.

1. Создать выделенную сеть:
Заходим в create VPC. В настройках выбираем "VPC and more", чтобы сразу задать количество AZ и количество public  и pricate subnets, IGW и route tables. Выбираем AZ eu-north-1a, eu-north-2b, eu-north-3c. Публичные будут в eu-north-1a, eu-north-2b, приватная в eu-north-3c. Создадим ещё одну ACL и добавим ассоциацию с eu-north-3c subnet и разрешим inboud и outbound трафик только для 10.0.0.0/16, на все остальное ограничиваем.
	
2.  Создадим Security group, указываем наш VPC. В Inbound rules добавим правило для 22  порта и моего ip, 80 порта и 443. В outbound запишем All trafic, 0.0.0.0/0

3. Заходим в Create key pair, создадим ключ с названием web-sg

4. Создадим 2 EC2 инстанса в разных публичных подсетях, ключ будем использовать web-sg, secoutiry group создадим новый для этой же vpc. Добавим публичные IP через Elastic IP address. Установим nginx, создадим index.html и положим в /usr/share/nginx/html. В этой html для каждого инстанса напишем имя сервера в h заголовке, чтобы знать, что сервера меняются.

5. Заходим в Load Balancing->Load Balancers. Создаём classic load balancer, выбираем наш VPC, выбираем 2 public subnets, схему выбираем Internet-facing, аттачим наши EC2 инстансы. Создадим secoutiry group только для HTTP. Добавил дефолтный Health check c минимальными ответами. HealthCheck показывает для обоих инстансов In-service. Проверяем по выданному домену что показывает: LoadBalancerHomeWork-1223390692.eu-north-1.elb.amazonaws.com. Отключим server 2, по домену все ещё выдаёт сайт

6. Создать RDS:
	6.1. Заходим в RDS, нажимаем create database, выбираем:
	engine type - PostgreSQL
	templates   - Free tier
	Deployment  - Single DB instance
	
	Далее указывает master username, password.
	
	Instance     		- db.t3.micro
	Storage type 		- general purpose ssd (gp2)
	Allocatage storage  - 20 GiB
	
	Выбираем наш сеть VPC. 
	Public access - No.
	Выбираем VPC secutity group из пункта 6.2. RDS подключил все 3 подсети, отключим 2 публичные.
	В additional port - 5432, добавим его в web-sg secoutiry group.
	
	Попробуем приконектиться из server1 к нашей бд по этому url: homework-database.ckhbxxixmdou.eu-north-1.rds.amazonaws.com
	
	Установим клиент psql. Посмотрим какие клиенты доступны: 
	sudo yum search "postgres"
	
	Доступна 15 версия, установим её:
	sudo yum install postgresql15
	
	Приконнектимся:
	psql --host=homework-database.ckhbxxixmdou.eu-north-1.rds.amazonaws.com --port=5432 --username=postgres --password 
	
	Сработало, мы зашли в бд. Сделаем ту же процедуру с сервера 2

7. ElastiCache:
	7.1. Создание инстанса ElastiCache (Redis):
	В AWS Management Console переходим в ElastiCache, указываем Redis. 
	Выбираем configure and  create cluster.
	Отключим MultiAZ
	Выбираем инстанс micro.
	Выбираем 1 ноду.
	Выбираем выделенную VPC. Создадим security group чтобы, добавим туда CIDR наших серверов.
	После создания инстанса Redis, устнавим клиент на сервер 1 по этой инструкции
	https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/nodes-connecting.html
	используем команду redis-cli -h redisclaster.ac7uay.ng.0001.eun1.cache.amazonaws.com:6379 -p 6379 на EC2 инстансах для проверки подключения.
	
	7.2. Создание инстанса ElastiCache (Memcached):
	Выбираем Memcached.
	Standart create.
	AWS Cloud.
	Порт оставляем дефолтным (11211).
	Выбираем инстанс micro.
	Выбираем 1 ноду.
	Выбираем выделенную VPC. Создадим security group чтобы, добавим туда CIDR наших серверов.
	
8. CloudFront и S3:
	8.1. Создание CloudFront Distribution:
	Для начала создадим S3 bucket "homework-evgmos". В lifecycle rule укажим весь бакет, в actions выбираем Move current versions of objects between storage classes. Указываем Glacier Deep archive, 30 дней. В Expire current versions of objects указываем 180 дней.Вот такой граф мне выдал Амазон:
	{ Review transition and expiration actions
	Current version actions
	Day 0
	Objects uploaded
	Day 30
	Objects move to Glacier Deep Archive
	Day 180
	Objects expire }
	
	В AWS Management Console переходим в CloudFront.
	Нажимаем "Create Distribution".
	В origin domain указываем наш S3 bucket "homework-evgmos".
	В origin access указываем Legacy access identities. Он нам выдаёт origin access identity: 
	Остально по умолчанию.
	
	Загружаем в бакет пару картинок.
	
Часть 2.

11. 
	1. Установим EB с помощью питона: pip install awsebcli --upgrade --user. В переменные окружения добавим      
	   C:\Users\user\AppData\Roaming\Python\Python310\Scripts
	   Проверим: eb --version
	   EB CLI 3.20.10 (Python 3.10.9 | packaged by Anaconda, Inc. | (main, Mar  1 2023, 18:18:15) [MSC v.1916 64 bit (AMD64)])
	
	2. Создадим руби проект и докер файл.
	3. Зайдём в папку руби проекта и пропишем eb init, выбирем eu-north-1 регион, выберем название проекта, выберем Ruby язык, версию 3.2,  ECS running on 64bit Amazon Linux 2023
	4. Настроим nginx, создадим nginx.conf и докер файл
	5. Добавим Dockerrun.aws.json и пропишем eb create
	Логи:
	Environment details for: itransition-homework-dev
	  Application name: itransition-homework
	  Region: eu-north-1
	  Deployed Version: app-231124_014709745753
	  Environment ID: e-fi9cmxfuwg
	  Platform: arn:aws:elasticbeanstalk:eu-north-1::platform/ECS running on 64bit Amazon Linux 2023/4.0.1
	  Tier: WebServer-Standard-1.0
	  CNAME: itransition-homework-dev.eu-north-1.elasticbeanstalk.com
	  Updated: 2023-11-23 21:47:18.655000+00:00
	Printing Status:
	2023-11-23 21:47:17    INFO    createEnvironment is starting.
	2023-11-23 21:47:18    INFO    Using elasticbeanstalk-eu-north-1-779246747823 as Amazon S3 storage bucket for environment data.
	2023-11-23 21:47:39    INFO    Created security group named: sg-0c9fb661570066473
	2023-11-23 21:47:39    INFO    Created load balancer named: awseb-e-f-AWSEBLoa-1MYDUOO67BKQT
	2023-11-23 21:47:56    INFO    Created security group named: awseb-e-fi9cmxfuwg-stack-AWSEBSecurityGroup-ZTN8SF04PDEJ
	2023-11-23 21:47:57    INFO    Created Auto Scaling launch configuration named: awseb-e-fi9cmxfuwg-stack-AWSEBAutoScalingLaunchConfiguration-sGCib9lqMAdQ
	2023-11-23 21:48:13    INFO    Created Auto Scaling group named: awseb-e-fi9cmxfuwg-stack-AWSEBAutoScalingGroup-aUYOYj9v2HlY
	2023-11-23 21:48:13    INFO    Waiting for EC2 instances to launch. This may take a few minutes.
	2023-11-23 21:48:13    INFO    Created Auto Scaling group policy named: arn:aws:autoscaling:eu-north-1:779246747823:scalingPolicy:476513c0-b70d-4471-b0b9-f17eca957507:autoScalingGroupName/awseb-e-fi9cmxfuwg-stack-AWSEBAutoScalingGroup-aUYOYj9v2HlY:policyName/awseb-e-fi9cmxfuwg-stack-AWSEBAutoScalingScaleUpPolicy-AdfvOpMqbfif
	2023-11-23 21:48:13    INFO    Created Auto Scaling group policy named: arn:aws:autoscaling:eu-north-1:779246747823:scalingPolicy:b22aa976-1aa3-4345-aaee-404d029c495e:autoScalingGroupName/awseb-e-fi9cmxfuwg-stack-AWSEBAutoScalingGroup-aUYOYj9v2HlY:policyName/awseb-e-fi9cmxfuwg-stack-AWSEBAutoScalingScaleDownPolicy-D83DxOYNX7Wn
	2023-11-23 21:48:29    INFO    Created CloudWatch alarm named: awseb-e-fi9cmxfuwg-stack-AWSEBCloudwatchAlarmHigh-EDrlakqxXw93
	2023-11-23 21:48:29    INFO    Created CloudWatch alarm named: awseb-e-fi9cmxfuwg-stack-AWSEBCloudwatchAlarmLow-YZoj0W2z7Rn6
	2023-11-23 21:51:07    INFO    Successfully launched environment: itransition-homework-dev
	
	6. Далее деплоим eb deploy
	Логи:
	Creating application version archive "app-231124_020132885045".
	Uploading itransition-homework/app-231124_020132885045.zip to S3. This may take a while.
	Upload Complete.
	2023-11-23 22:01:39    INFO    Environment update is starting.
	2023-11-23 22:01:49    INFO    Deploying new version to instance(s).
	2023-11-23 22:03:20    INFO    New application version was deployed to running EC2 instances.
	2023-11-23 22:03:20    INFO    Environment update completed successfully.
	
	7. Заходим на itransition-homework-dev.eu-north-1.elasticbeanstalk.com, страница Не открывается.
	8. eb logs, смотрим логи. Я не запушил контейнеры в докер хаб. Исправляем это.
	9. Добавим изменения в гит, и ещё раз пропишем eb deploy.
	10. Все работает

Часть 3.
	1. Создадим два инстанса, server1, server2.
	2. В secutity group разрешим доступ по ssh и порт 8080
	3. Можно установить Jenkins через докер, как я уже это делал, на этот раз я его установлю локально.
		sudo yum install java-11-amazon-corretto - для установки java
		sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
		sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
		sudo yum install jenkins -y
		sudo service jenkins start
	4. Найдём токен в /var/lib/jenkins/secrets/initialAdminPassword и создадим пользователя
	5. На server 1 создадим ключ
	   ssh-keygen -t rsa -b 4096 -C "zhekamoskovcev@yandex.ru"
	   и закинем содержимое публичного ключа в ~/.ssh/authorized_keys в server 2
	6. Проверим, зайдём с server1 на server2
	7. Устанавливаем докер на server2:
	   sudo yum install docker
	   sudo usermod -a -G docker ec2-user
	   newgrp docker - Это для того, чтобы не выходить из консоли и сразу пользоваться докером
	
	8. Создадим credentials в Jenkins.
	9. Запушим Jenkins file в репозиторий. 
	10. В настройках нашего job, добавим переменную STAGE_INSTANCE, чтобы она была прописана только локально
	11. Job не запускается, проблема в known_hosts. Добавим наш сервер: ssh-keyscan -H 172.31.38.191 >> ~/.ssh/known_hosts
	   
	
	
	
	
	
	
		
		
		