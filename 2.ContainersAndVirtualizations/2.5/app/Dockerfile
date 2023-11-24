FROM python:3.9-alpine

#RUN apt-get update && \
#	apt-get upgrade -y

WORKDIR /app

COPY ./requirements.txt .

RUN python3 -m pip install -r requirements.txt

COPY ./app.py .

ENTRYPOINT ["python3", "app.py"]