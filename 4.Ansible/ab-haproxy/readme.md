1. Зашифруем пароль с помощью ansible-vault encrypt_string 'vagrant' --name 'ansible_password'
2. Распишу роли для apt и ntp, для monit возьму из github роль и покывыраюсь (адаптирую) в ней, уберу вебморду и почтовые сервисы, для haproxy возьму из galaxy
3. Напишем инвентарь
4. для запуска плейбука используем команду ansible-playbook -i inventory.ini playbook.yaml --ask-vault-pass
5. Посмотрим на логи monit:
cat /var/log/monit.log
[UTC Nov 25 16:12:47] info     :  New Monit id: 296ba7f280ab875879439c56685de182
 Stored in '/var/lib/monit/id'
[UTC Nov 25 16:12:47] info     : Starting Monit 5.26.0 daemon
[UTC Nov 25 16:12:47] info     : 'ubuntu-2004-test' Monit 5.26.0 started
[UTC Nov 25 16:39:26] info     : Monit daemon with pid [27825] stopped
[UTC Nov 25 16:39:26] info     : 'ubuntu-2004-test' Monit 5.26.0 stopped
[UTC Nov 25 16:40:58] info     : Starting Monit 5.26.0 daemon
[UTC Nov 25 16:40:58] info     : 'ubuntu-2004-test' Monit 5.26.0 started
[UTC Nov 25 16:49:10] info     : Monit daemon with pid [34593] stopped
[UTC Nov 25 16:49:10] info     : 'ubuntu-2004-test' Monit 5.26.0 stopped
[UTC Nov 25 16:49:10] info     : Starting Monit 5.26.0 daemon
[UTC Nov 25 16:49:10] info     : 'ubuntu-2004-test' Monit 5.26.0 started

