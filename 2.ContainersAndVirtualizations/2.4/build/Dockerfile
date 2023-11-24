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