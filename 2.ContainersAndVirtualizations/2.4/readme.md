Создадим простой flask app

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Привет, мир!"

if __name__ == '__main__':
    app.run(host='localhost', port=8888)


Напишем для него Dockerfile

FROM ubuntu:20.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python3 && \
    apt-get install -y python3-pip
	
WORKDIR /app

COPY ../requirements.txt requirements.txt
RUN python3 -m pip install -r requirements.txt

COPY ../app .

EXPOSE 8888
ENTRYPOINT ["python3", "app.py"]

Чтобы сбилдить контейнер, пропишем

docker build -t webapp -f build\Dockerfile .

Чтобы запустить
docker run -p 8888:8888 webapp

Запустим и зайдём на localhost:8888
Посмотрим, что в консоли:

D:\Study\itransition_devops\DevOps_course\2.ContainersAndVirtualizations\2.4>docker run -p 8888:8888 webapp
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8888
 * Running on http://172.17.0.2:8888
Press CTRL+C to quit
172.17.0.1 - - [24/Oct/2023 22:25:58] "GET / HTTP/1.1" 200 -
172.17.0.1 - - [24/Oct/2023 22:25:58] "GET /favicon.ico HTTP/1.1" 404 -

Пропишем docker stop айди_контейнера
для того, чтобы остановить контейнер

И удалим контейнер
docker rmi айди_контейнера