Что сделано:
Я решил создать две виртуальные машины. 
На первой будет nginx, на второй postgresql. Сеть будет Host-network,
чтобы они общались между собой. Характеристики установил для nginx 1 cpu и 1048 мбайт,
для postgresql 2 cpu и 2096 мбайт. Для того, чтобы установить nginx на первой машине
я использовал данную команду:
wsconfig.vm.provision "nginx", type: "shell", inline: "apt-get install -y nginx"

Чтобы установить postgresql на второй машине, потребовалось написать скрипт, чтобы
установить репозитории и затем скачать

$install_postgresql = <<~SCRIPT
  sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo apt-get update
  sudo apt-get -y install postgresql
SCRIPT

dbconfig.vm.provision "postgresql", type: "shell", inline: $install_postgresql

Перед тем, как устаналивать nginx и postgresql, мы должны скачать свежие программы, для этого
скажем vagrant, чтобы он сделал apt-get update && apt-get upgrage
config.vm.provision "update", type: "shell", inline: "apt-get update && apt-get upgrade -y"

Зайдя на машину с nginx попробуем постучаться во вторую машину 

ping 192.168.53.4
PING 192.168.53.4 (192.168.53.4) 56(84) bytes of data.
64 bytes from 192.168.53.4: icmp_seq=1 ttl=64 time=0.841 ms
64 bytes from 192.168.53.4: icmp_seq=2 ttl=64 time=0.782 ms
64 bytes from 192.168.53.4: icmp_seq=3 ttl=64 time=0.610 ms
64 bytes from 192.168.53.4: icmp_seq=4 ttl=64 time=0.528 ms

Пакеты приходят, значит сеть есть.

Посмотрим, что с nginx
ps aux | grep nginx
root       16320  0.0  0.1  51208  1496 ?        Ss   18:36   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data   16321  0.0  0.5  51772  5092 ?        S    18:36   0:00 nginx: worker process
vagrant    16835  0.0  0.0   6300   724 pts/0    S+   18:52   0:00 grep --color=auto nginx

Демон работает.

Посмотрим, что с postgres

vagrant@postgresql-host:~$ ps aux | grep postgres
postgres   19416  0.0  1.4 217972 30204 ?        Ss   18:39   0:00 /usr/lib/postgresql/16/bin/postgres -D /var/lib/postgresql/16/main -c config_file=/etc/postgresql/16/main/postgresql.conf
postgres   19417  0.0  0.3 218116  8204 ?        Ss   18:39   0:00 postgres: 16/main: checkpointer
postgres   19418  0.0  0.2 218108  6044 ?        Ss   18:39   0:00 postgres: 16/main: background writer
postgres   19420  0.0  0.5 218108 10628 ?        Ss   18:39   0:00 postgres: 16/main: walwriter
postgres   19421  0.0  0.4 219584  8904 ?        Ss   18:39   0:00 postgres: 16/main: autovacuum launcher
postgres   19422  0.0  0.4 219564  8728 ?        Ss   18:39   0:00 postgres: 16/main: logical replication launcher
vagrant    21246  0.0  0.0   6432   724 pts/0    S+   18:55   0:00 grep --color=auto postgres

Тоже работает