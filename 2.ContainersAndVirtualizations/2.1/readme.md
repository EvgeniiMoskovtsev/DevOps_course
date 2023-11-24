Что сделано:
Первым делом было опробовано запустить vagrant на wsl2. Оказывается, это не просто, т.к. valgrand не мог подключиться по ssh к виртуальной машине и было решено перейти на основую систему windows 10. 
Далее был написан Valgrand файл, 2048 мегабайт оперативной памяти, 1 ядром и сетью public. Провайдер был выбрал VirtualBox. Образ был взять bento/ubuntu-20.04
{
config.vm.box = "bento/ubuntu-20.04"
config.vm.provider "virtualbox" do |vb|
	vb.name = "ubuntu-2004"
	vb.memory = 2048
	vb.cpus = 1
end
config.vm.hostname = "ubuntu-2004"
config.vm.network "public_network"
}

Для того, чтобы создать виртуальную машину, была прописана команда:
vagrant up

Для того, чтобы попасть на неё
vagrant ssh

На Ubuntu-20.04 от Bento не было ifconfig, поэтому сразу же обновил репозитории 
sudo apt-get update

и

sudo apt-get install net-tools

ifconfig выдал два сетевых интерфейса

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fe80::a00:27ff:fe06:38eb  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:06:38:eb  txqueuelen 1000  (Ethernet)
        RX packets 25673  bytes 35202963 (35.2 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 2720  bytes 295012 (295.0 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.100.6  netmask 255.255.255.0  broadcast 192.168.100.255
        inet6 fe80::a00:27ff:fe39:4d13  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:39:4d:13  txqueuelen 1000  (Ethernet)
        RX packets 14617  bytes 20809850 (20.8 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3471  bytes 278727 (278.7 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
		

Далее для остановки виртуальной машины была использована команда
vagrant halt

и для её удаления
vagrant destroy