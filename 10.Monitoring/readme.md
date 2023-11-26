Задача 1. 
1. Запустим кластер с 1 нодой:
	minikube start
	
2. Установим prometheus с графаной помощью helm
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update

3. Установим на кластер
	helm install prometheus prometheus-community/prometheus
	helm install grafana grafana/grafana


4. Удостоверимся, что можем зайти на веб морду посмотрим сервисы


Чтобы настроить 
$ kubectl get svc
NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
grafana                               ClusterIP   10.99.112.71     <none>        80/TCP     25m
kubernetes                            ClusterIP   10.96.0.1        <none>        443/TCP    31d
prometheus-alertmanager               ClusterIP   10.106.207.89    <none>        9093/TCP   46m
prometheus-alertmanager-headless      ClusterIP   None             <none>        9093/TCP   46m
prometheus-kube-state-metrics         ClusterIP   10.108.241.111   <none>        8080/TCP   46m
prometheus-prometheus-node-exporter   ClusterIP   10.107.24.43     <none>        9100/TCP   46m
prometheus-prometheus-pushgateway     ClusterIP   10.111.11.195    <none>        9091/TCP   46m
prometheus-server                     ClusterIP   10.111.35.217    <none>        80/TCP     46m


5. Зайдём на вебморду, для этого прокинем порты: 
kubectl port-forward svc/prometheus-server 9090:80

6. В графане в administrations->plugins установим плагим Prometheus
7. В Connections->Data sources укажем 10.111.35.217:80 для считывания данных

Задача 2.
1. Создадим дашборд, укажем prometheus_http_requests_total, и job=prometheus, таймфрейм 15 минут

Задача 3.
-

Задача 4.
1. Увеличим количество реплик до 4
kubectl scale deployment prometheus-server --replicas 4
2. Зададим метрику memory cpu
3. График растет вверх
4. Увеличим реплики до 15, половина реплик крашнулось, но график все равно подрос

C:\Users\user>kubectl get pods
NAME                                                 READY   STATUS              RESTARTS        AGE
grafana-696b49-snpjj                                 1/1     Running             0               71m
prometheus-alertmanager-0                            1/1     Running             0               92m
prometheus-kube-state-metrics-85596bfdb6-xgsvc       1/1     Running             0               92m
prometheus-prometheus-node-exporter-mbqvn            1/1     Running             0               92m
prometheus-prometheus-pushgateway-79745d4495-589js   1/1     Running             0               92m
prometheus-server-678f7c8df8-25x7h                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-42xtf                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-6qkk8                   2/2     Running             0               21m
prometheus-server-678f7c8df8-cvwxn                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-f2mmg                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-ffsfb                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-hwncz                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-lshlk                   1/2     CrashLoopBackOff    6 (3m22s ago)   9m3s
prometheus-server-678f7c8df8-mtpx7                   1/2     CrashLoopBackOff    6 (3m16s ago)   9m3s
prometheus-server-678f7c8df8-p2cz6                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-rbh4r                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-v2fmb                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-vjqb9                   0/2     ContainerCreating   0               12s
prometheus-server-678f7c8df8-w7hb9                   1/2     CrashLoopBackOff    6 (3m9s ago)    9m3s
prometheus-server-678f7c8df8-xjjjl                   0/2     ContainerCreating   0               12s

