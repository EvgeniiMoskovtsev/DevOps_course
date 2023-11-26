1. Apt, ntp, monit повторим из ab-proxy, java установим через galaxy ansible-galaxy role install andrewrothstein.openjdk, logstash и elasticsearch взял с официальной документации.
Логи с запуска ansible:
evgenii@WIN-F4ADU8QV9DV:/mnt/d/Study/itransition_devops/4.Ansible/ab-logstash$ ansible-playbook -i inventory.ini playbook.yaml --ask-vault-pass
Vault password:
[DEPRECATION WARNING]: "include" is deprecated, use include_tasks/import_tasks instead. This feature will be removed in
 version 2.16. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.

PLAY [All configs] *****************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
[WARNING]: error loading facts as JSON or ini - please check content: /etc/ansible/facts.d/monit.fact
ok: [172.24.91.200]

TASK [apt : Install git] ***********************************************************************************************
ok: [172.24.91.200]

TASK [apt : Install vim] ***********************************************************************************************
ok: [172.24.91.200]

TASK [apt : Update all packages to the latest version] *****************************************************************
ok: [172.24.91.200]

TASK [ntp : Install ntp] ***********************************************************************************************
ok: [172.24.91.200]

TASK [ntp : Configure NTP server to use Europe pool] *******************************************************************
ok: [172.24.91.200]

TASK [ntp : Schedule ntp sync daily] ***********************************************************************************
ok: [172.24.91.200]

TASK [ntp : Restart NTP service] ***************************************************************************************
changed: [172.24.91.200]

TASK [monit : pkg - Install package] ***********************************************************************************
ok: [172.24.91.200]

TASK [monit : create includes folder] **********************************************************************************
ok: [172.24.91.200]

TASK [monit : create lib folder] ***************************************************************************************
ok: [172.24.91.200]

TASK [monit : config - Setup monitrc] **********************************************************************************
ok: [172.24.91.200]

TASK [monit : monitors - Write monitors] *******************************************************************************
ok: [172.24.91.200] => (item={'name': 'monit', 'type': 'process', 'target': '/var/run/monit.pid'})
ok: [172.24.91.200] => (item={'name': 'system_cpu', 'type': 'system', 'rules': ['if loadavg (1min) > 4 for 2 cycles then alert', 'if loadavg (5min) > 2 for 4 cycles then alert']})
ok: [172.24.91.200] => (item={'name': 'system_memory', 'type': 'system', 'rules': ['if memory usage > 75% for 4 cycles then alert']})
ok: [172.24.91.200] => (item={'name': 'root_filesystem', 'type': 'filesystem', 'target': '/', 'rules': ['if space usage > 80% for 2 cycles then alert']})

TASK [monit : monitors - Create facts directory] ***********************************************************************
ok: [172.24.91.200]

TASK [monit : monitors - Registers configured monitors] ****************************************************************
ok: [172.24.91.200]

TASK [monit : monitors - Reload facts] *********************************************************************************
skipping: [172.24.91.200]

TASK [monit : monitors - List configured monitors] *********************************************************************
ok: [172.24.91.200]

TASK [monit : monitors - Remove unused monitors] ***********************************************************************
skipping: [172.24.91.200] => (item=haproxy)
skipping: [172.24.91.200] => (item=monit)
skipping: [172.24.91.200] => (item=root_filesystem)
skipping: [172.24.91.200] => (item=system_cpu)
skipping: [172.24.91.200] => (item=system_memory)
skipping: [172.24.91.200] => (item=test2)

TASK [monit : service - ensure running and enabled] ********************************************************************
ok: [172.24.91.200]

TASK [include_role : andrewrothstein.unarchive-deps] *******************************************************************

TASK [andrewrothstein.unarchive-deps : resolve platform specific vars] *************************************************
ok: [172.24.91.200] => (item=/home/evgenii/.ansible/roles/andrewrothstein.unarchive-deps/vars/Debian.yml)

TASK [andrewrothstein.unarchive-deps : install OS packages] ************************************************************
ok: [172.24.91.200]

TASK [andrewrothstein.unarchive-deps : install PowerShell module] ******************************************************
skipping: [172.24.91.200]

TASK [include_role : andrewrothstein.alpineglibcshim] ******************************************************************

TASK [andrewrothstein.alpineglibcshim : fix alpine] ********************************************************************
skipping: [172.24.91.200]

TASK [andrewrothstein.openjdk : resolve platform specific vars] ********************************************************

TASK [andrewrothstein.openjdk : mkdir /usr/local/openjdk] **************************************************************
ok: [172.24.91.200]

TASK [andrewrothstein.openjdk : looking for install subdir at /usr/local/openjdk/jdk-16.0.1+9...] **********************
ok: [172.24.91.200]

TASK [andrewrothstein.openjdk : downloading https://github.com/AdoptOpenJDK/openjdk16-binaries/releases/download/jdk-16.0.1%2B9/OpenJDK16U-jdk_x64_linux_hotspot_16.0.1_9.tar.gz...] ***
changed: [172.24.91.200]

TASK [andrewrothstein.openjdk : unarchiving /tmp/OpenJDK16U-jdk_x64_linux_hotspot_16.0.1_9.tar.gz to /usr/local/openjdk...] ***
changed: [172.24.91.200]

TASK [andrewrothstein.openjdk : deleting /tmp/OpenJDK16U-jdk_x64_linux_hotspot_16.0.1_9.tar.gz...] *********************
changed: [172.24.91.200]

TASK [andrewrothstein.openjdk : linking /usr/local/openjdk-jdk to /usr/local/openjdk/jdk-16.0.1+9...] ******************
changed: [172.24.91.200]

TASK [andrewrothstein.openjdk : adding openjdk to default path and easing systemd integration...] **********************
changed: [172.24.91.200] => (item={'f': 'openjdk.sh', 'd': '/etc/profile.d'})
changed: [172.24.91.200] => (item={'f': 'openjdk.env', 'd': '/usr/local/openjdk/jdk-16.0.1+9'})

TASK [logstash : Install required pkgs] ********************************************************************************
changed: [172.24.91.200]

TASK [logstash : Add GPG keys] *****************************************************************************************
changed: [172.24.91.200]

TASK [logstash : Add repo Elastic] *************************************************************************************
changed: [172.24.91.200]

TASK [logstash : Install Logstash] *************************************************************************************
changed: [172.24.91.200]

TASK [elasticsearch : Install Elasticsearch] ***************************************************************************
changed: [172.24.91.200]

PLAY RECAP *************************************************************************************************************
172.24.91.200              : ok=31   changed=11   unreachable=0    failed=0    skipped=5    rescued=0    ignored=0