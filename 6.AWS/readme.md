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
	   
	2. Зайдём в папку и пропишем eb init, выбирем eu-north-1 регион, выберем название проекта, выберем Ruby язык, версию 3.2
	
	
		
		
		