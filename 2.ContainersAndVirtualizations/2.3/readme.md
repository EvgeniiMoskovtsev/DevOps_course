Т.к. ansible не работает на windows, я установил его на wsl.
Установил виртуальную машину как в пункте 1, использовал образ bento/ubuntu-20.04
сеть поставил bridge, подсеть установил ту же, где и wsl.

wsl
{eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1472
        inet 172.24.91.157  netmask 255.255.240.0  broadcast 172.24.95.255
        inet6 fe80::215:5dff:fe72:288a  prefixlen 64  scopeid 0x20<link>
        ether 00:15:5d:72:28:8a  txqueuelen 1000  (Ethernet)
        RX packets 199  bytes 29358 (29.3 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 31  bytes 2186 (2.1 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0}

vagrant
{eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.24.91.200  netmask 255.255.255.0  broadcast 172.24.91.255
        inet6 fe80::a00:27ff:fe64:1d9c  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:64:1d:9c  txqueuelen 1000  (Ethernet)
        RX packets 6  bytes 452 (452.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 18  bytes 1386 (1.3 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0}
		

Первая проблема, с котрой я столкнулся, это то, что vagrant ssh-config показывает конфинг
{Host default
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /.vagrant/machines/default/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
  PubkeyAcceptedKeyTypes +ssh-rsa
  HostKeyAlgorithms +ssh-rsa}
  
Но по этому хосту и порту никак не достучаться, поэтому я использовал порт по умолчанию 22 ssh -i .vagrant/machines/default/virtualbox/private_key 172.24.91.200:22 - так зашло.

Далее изучая ansible я сначала написал простой инвертарь, и использовал модуль ping, что проверить, что ответ приходит

[staging_server]
172.24.91.200

Создадим в group_vars файл staging_server.yml
---
ansible_user: vagrant
ansible_password: vagrant


Запуск:
ansible staging_server -i hosts.ini -m ping 

172.24.91.200 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}

Напишу простой плейбук для поднятия nginx
---
- name: Preconfig Ubuntu
  hosts: staging_server
  become: yes
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: latest
        
    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes
        
    - name: Add cron job to remove logs every 1 minutes
      ansible.builtin.cron:
        name: "remove logs"
        job: "rm -r /var/log"
		


Запуск:
ansible-playbook -i hosts.ini config.yml

Проверяем:
vagrant@ubuntu-2004-test:~$ service nginx status
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2023-10-18 13:55:06 UTC; 2min 38s ago
       Docs: man:nginx(8)
   Main PID: 2668 (nginx)
      Tasks: 2 (limit: 2257)
     Memory: 5.8M
     CGroup: /system.slice/nginx.service
             ├─2668 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             └─2669 nginx: worker process

Oct 18 13:55:06 ubuntu-2004-test systemd[1]: Starting A high performance web server and a reverse proxy server...
Oct 18 13:55:06 ubuntu-2004-test systemd[1]: Started A high performance web server and a reverse proxy server.

Посмотрим cron job

vagrant@ubuntu-2004-test:/var/log$ ls
alternatives.log  btmp                   dmesg.0     firewalld  landscape  syslog
apt               cloud-init.log         dmesg.1.gz  installer  lastlog    syslog.1
auth.log          cloud-init-output.log  dpkg.log    journal    nginx      ubuntu-advantage.log
bootstrap.log     dmesg                  faillog     kern.log   private    wtmp
vagrant@ubuntu-2004-test:/var/log$ date
Tue 24 Oct 2023 06:32:02 PM UTC
vagrant@ubuntu-2004-test:/var/log$ ls -la
total 0
vagrant@ubuntu-2004-test:/var/log$ date
Tue 24 Oct 2023 06:32:13 PM UTC