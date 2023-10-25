Я решил сделать web приложение Flask + Nginx + PostgreSql

Я начал с приложения flask (app.py)
Вот основной код :
def create_connection():
    try:
        conn = psycopg2.connect(
            dbname=os.environ.get("POSTGRES_DB", "example"),
            user="postgres",
            password=os.environ.get("POSTGRES_PASSWORD", "postgres"),
            host="db"
        )
        return conn
    except OperationalError as e:
        print(f"The error '{e}' occurred")
        return None

@app.route('/')
def hello():
    connection = create_connection()
    if connection:
        connection.close()
        return "Привет, мир! PostgreSQL успешно подключен."
    else:
        return "Привет, мир! Не удалось подключиться к PostgreSQL."


Здесь я подключаюсь к хосту и если успешно подключился к базе данных,
то значит все хорошо)

Перейдём теперь к Dockerfile этого приложения. Я использовал image python3.9 alpine, т.к. он легковесный и мне его достаточно, чтобы запустить сервер с flask

FROM python:3.9-alpine

Остальное я взял с предыдущего задания (2.4)

Nginx я буду использовать как reverse proxy, для этого надо сделать конфиг:
server {
	listen 80;
	location / {
		proxy_pass http://backend:8888/;
	}
}

Здесь я говорю, чтобы он слушал порт 80 (http) и проксировал запросы на backend 
на порт 8888.
Далее напишу, откуда этот хост появился.

Осталось написан docker compose файл, чтобы запустить все три контейнера.
По дефолту они запускаются в одной сети, так что сеть прокладывать не надо.

Вот описание flask приложения 

backend:
build:
  context: ./app
depends_on:
  db:
	condition: service_healthy
environment:
  - POSTGRES_DB=test
  - POSTGRES_PASSWORD=postgres
 
Как раз отсюда и появляется хост backend. Здесь я прописываю какую папку билдить
(context), открывать порты мне не нужно, т.к. у меня есть nginx.
Далее я делаю зависимость от db. Но также указывают, что сервис должен быть "здоров", это нужно т.к. если я бы просто написал:

depends_on:
  - db
То перед контейнером backend запустился бы db, но мне также нужно, чтобы база данных была готова принимать соединения. Про это я напишу далее. И также я указал env переменные, которые будет использовать flask, чтобы подключиться к db.


db:
image: postgres
restart: always
user: postgres
environment:
  - POSTGRES_DB=test
  - POSTGRES_PASSWORD=postgres
healthcheck:
  test: ["CMD", "pg_isready"]
  interval: 10s
  timeout: 5s
  retries: 5
 
Здесь я описываю db, я взял образ postgres. Указываю ему, что если он упадет, то ему нужно перезагрузиться. Следующая переменная "user", это с чем я столкнулся, по незнанию. Если её не указывать, то postgres запускается от root, а такого пользователя по дефолту нет. Далее указываю переменные окружения, чтобы база данных загрузилась. И самое интересное - это healthcheck. Наличие healthcheck гарантирует, что сервис backend будет запущен только после того, как БД станет доступной. Однако это не гарантирует успешное подключение к БД из-за других проблем (например, неверные учетные данные)

Далее остался nginx.
proxy:
image: nginx
volumes:
  - type: bind
	source: ./proxy/default.conf
	target: /etc/nginx/conf.d/default.conf
	read_only: true
ports:
  - 80:80
depends_on: 
  - backend

Я взял образ nginx и в volumes указал bind, чтобы не создавать объекты.
Далее я прописал путь на хост машине и куда положить в контейнер. 
Для большей безопасности я прописал флаг read_only: true, так как нам нужно только читать этот файл. Далее все просто: указал какие порты мапить и чтобы этот контейнер запустился после backend.

После запуска docker compose, я зашёл на http://localhost:80 и увидел сообщение
Привет, мир! PostgreSQL успешно подключен.

Значит, все работает.
Команды, которые я использовал:
docker compose up
docker compose down

Логи с консоли:

docker compose up
[+] Running 4/4
 - Network 25_default      Created                                                                                                                                                                                 0.0s
 - Container 25-db-1       Created                                                                                                                                                                                 0.1s
 - Container 25-backend-1  Created                                                                                                                                                                                 0.1s
 - Container 25-proxy-1    Created                                                                                                                                                                                 0.1s
Attaching to 25-backend-1, 25-db-1, 25-proxy-1
25-db-1       | The files belonging to this database system will be owned by user "postgres".
25-db-1       | This user must also own the server process.
25-db-1       |
25-db-1       | The database cluster will be initialized with locale "en_US.utf8".
25-db-1       | The default database encoding has accordingly been set to "UTF8".
25-db-1       | The default text search configuration will be set to "english".
25-db-1       |
25-db-1       | Data page checksums are disabled.
25-db-1       |
25-db-1       | fixing permissions on existing directory /var/lib/postgresql/data ... ok
25-db-1       | creating subdirectories ... ok
25-db-1       | selecting dynamic shared memory implementation ... posix
25-db-1       | selecting default max_connections ... 100
25-db-1       | selecting default shared_buffers ... 128MB
25-db-1       | selecting default time zone ... Etc/UTC
25-db-1       | creating configuration files ... ok
25-db-1       | running bootstrap script ... ok
25-db-1       | performing post-bootstrap initialization ... ok
25-db-1       | syncing data to disk ... ok
25-db-1       |
25-db-1       |
25-db-1       | Success. You can now start the database server using:
25-db-1       |
25-db-1       |     pg_ctl -D /var/lib/postgresql/data -l logfile start
25-db-1       |
25-db-1       | initdb: warning: enabling "trust" authentication for local connections
25-db-1       | initdb: hint: You can change this by editing pg_hba.conf or using the option -A, or --auth-local and --auth-host, the next time you run initdb.
25-db-1       | waiting for server to start....2023-10-25 16:25:11.800 UTC [35] LOG:  starting PostgreSQL 16.0 (Debian 16.0-1.pgdg120+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit
25-db-1       | 2023-10-25 16:25:11.803 UTC [35] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
25-db-1       | 2023-10-25 16:25:11.812 UTC [38] LOG:  database system was shut down at 2023-10-25 16:25:11 UTC
25-db-1       | 2023-10-25 16:25:11.816 UTC [35] LOG:  database system is ready to accept connections
25-db-1       |  done
25-db-1       | server started
25-db-1       | CREATE DATABASE
25-db-1       |
25-db-1       |
25-db-1       | /usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*
25-db-1       |
25-db-1       | waiting for server to shut down...2023-10-25 16:25:11.974 UTC [35] LOG:  received fast shutdown request
25-db-1       | .2023-10-25 16:25:11.977 UTC [35] LOG:  aborting any active transactions
25-db-1       | 2023-10-25 16:25:11.978 UTC [35] LOG:  background worker "logical replication launcher" (PID 41) exited with exit code 1
25-db-1       | 2023-10-25 16:25:11.978 UTC [36] LOG:  shutting down
25-db-1       | 2023-10-25 16:25:11.980 UTC [36] LOG:  checkpoint starting: shutdown immediate
25-db-1       | 2023-10-25 16:25:12.064 UTC [36] LOG:  checkpoint complete: wrote 923 buffers (5.6%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.011 s, sync=0.060 s, total=0.087 s; sync files=301, longest=0.013 s, average=0.001 s; distance=4257 kB, estimate=4257 kB; lsn=0/19130D0, redo lsn=0/19130D0
25-db-1       | 2023-10-25 16:25:12.068 UTC [35] LOG:  database system is shut down
25-db-1       |  done
25-db-1       | server stopped
25-db-1       |
25-db-1       | PostgreSQL init process complete; ready for start up.
25-db-1       |
25-db-1       | 2023-10-25 16:25:12.091 UTC [1] LOG:  starting PostgreSQL 16.0 (Debian 16.0-1.pgdg120+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit
25-db-1       | 2023-10-25 16:25:12.091 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
25-db-1       | 2023-10-25 16:25:12.091 UTC [1] LOG:  listening on IPv6 address "::", port 5432
25-db-1       | 2023-10-25 16:25:12.097 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
25-db-1       | 2023-10-25 16:25:12.103 UTC [51] LOG:  database system was shut down at 2023-10-25 16:25:12 UTC
25-db-1       | 2023-10-25 16:25:12.108 UTC [1] LOG:  database system is ready to accept connections
25-backend-1  |  * Serving Flask app 'app'
25-backend-1  |  * Debug mode: off
25-backend-1  | WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
25-backend-1  |  * Running on all addresses (0.0.0.0)
25-backend-1  |  * Running on http://127.0.0.1:8888
25-backend-1  |  * Running on http://172.25.0.3:8888
25-backend-1  | Press CTRL+C to quit
25-proxy-1    | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
25-proxy-1    | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
25-proxy-1    | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
25-proxy-1    | 10-listen-on-ipv6-by-default.sh: info: can not modify /etc/nginx/conf.d/default.conf (read-only file system?)
25-proxy-1    | /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
25-proxy-1    | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
25-proxy-1    | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
25-proxy-1    | /docker-entrypoint.sh: Configuration complete; ready for start up
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: using the "epoll" event method
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: nginx/1.25.3
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: OS: Linux 5.15.90.1-microsoft-standard-WSL2
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: start worker processes
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: start worker process 21
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: start worker process 22
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: start worker process 23
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: start worker process 24
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: start worker process 25
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: start worker process 26
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: start worker process 27
25-proxy-1    | 2023/10/25 16:25:22 [notice] 1#1: start worker process 28
25-proxy-1    | 172.25.0.1 - - [25/Oct/2023:16:25:28 +0000] "GET / HTTP/1.1" 200 67 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36" "-"
25-backend-1  | 172.25.0.4 - - [25/Oct/2023 16:25:28] "GET / HTTP/1.0" 200 -