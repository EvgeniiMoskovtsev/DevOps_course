Запускаю команду minikube start, логи:

minikube start
😄  minikube v1.31.2 on Microsoft Windows 10 Pro 10.0.19045.3570 Build 19045.3570
✨  Using the virtualbox driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🤷  virtualbox "minikube" VM is missing, will recreate.
🔥  Creating virtualbox VM (CPUs=2, Memory=6000MB, Disk=20000MB) ...
❗  This VM is having trouble accessing https://registry.k8s.io
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.27.4 on Docker 24.0.4 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🔎  Verifying Kubernetes components...

❗  C:\Program Files\Docker\Docker\resources\bin\kubectl.exe is version 1.25.4, which may have incompatibilities with Kubernetes 1.27.4.
    ▪ Want kubectl v1.27.4? Try 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default


В virtualbox у меня появилась машина minikube.

Пропишем в консоль kubectl cluster-info, логи:

Kubernetes control plane is running at https://192.168.59.104:8443
CoreDNS is running at https://192.168.59.104:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.


Теперь создадим pod. Напишем  my-pod.yaml. В качестве веб приложения 
будем использовать образ из задания 2.4

Сбилдим:
docker build -t emoskovtsev/flaskapp_2.4 -f build\Dockerfile .
И запушим в docker hub:
docker push emoskovtsev/flask-app-2-4-pod:latest


Проверим, что он есть
docker images

REPOSITORY     TAG       IMAGE ID       CREATED         SIZE
emoskovtsev/flaskapp_2.4   latest    82a34fd8d45c   8 seconds ago   446MB
25-backend     latest    68cfae2cda6a   2 hours ago     66.5MB
nginx          latest    593aee2afb64   16 hours ago    187MB
postgres       latest    f7d9a0d4223b   5 weeks ago     417MB

В my-pod.yaml пропишем наш локальный контейнер
spec:
  containers:
  - name: flask-app-2-4-pod
    image: emoskovtsev/flask-app-2-4-pod:latest
    ports:
     - containerPort: 8888
	 

Запускаем kubectl apply -f my-pod.yaml, логи:

error: error when retrieving current configuration of:
Resource: "/v1, Resource=pods", GroupVersionKind: "/v1, Kind=Pod"
Name: "flask-app-2-4-pod", Namespace: "default"
from server for: "my-pod.yaml": Get "https://192.168.59.104:8443/api/v1/namespaces/default/pods/flask-app-2-4-pod": http2: client connection lost

Не сработало.
Давайте посмотрим логи
kubectl describe pod flask-app-2-4-pod

  Warning  NetworkNotReady  6m6s                  kubelet            network is not ready: container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
  Warning  FailedMount      6m4s (x3 over 6m6s)   kubelet            MountVolume.SetUp failed for volume "kube-api-access-ptg6d" : object "default"/"kube-root-ca.crt" not registered
  Normal   SandboxChanged   6m2s                  kubelet            Pod sandbox changed, it will be killed and re-created.
  Warning  InspectFailed    2m21s                 kubelet            Failed to inspect image "flask-app-2-4-pod:latest": rpc error: code = Unknown desc = operation timeout: context deadline exceeded
  Warning  Failed           2m21s                 kubelet            Error: ImageInspectError
  Normal   Pulling          2m6s (x3 over 6m)     kubelet            Pulling image "flask-app-2-4-pod:latest"
  Warning  Failed           2m4s (x3 over 5m58s)  kubelet            Failed to pull image "flask-app-2-4-pod:latest": rpc error: code = Unknown desc = Error response from daemon: pull access denied for flask-app-2-4-pod, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
  Warning  Failed           2m4s (x3 over 5m58s)  kubelet            Error: ErrImagePull
  Normal   BackOff          95s (x3 over 5m57s)   kubelet            Back-off pulling image "flask-app-2-4-pod:latest"
  Warning  Failed           95s (x3 over 5m57s)   kubelet            Error: ImagePullBackOff
  

Я перезапустил minikube и удалить pod kubectl delete pod flask-app-2-4-pod 
и заново создал kubectl apply -f my-pod.yaml, теперь все ок

Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  20s   default-scheduler  Successfully assigned default/flask-app-2-4-pod to minikube
  Normal  Pulling    19s   kubelet            Pulling image "emoskovtsev/flask-app-2-4-pod:latest"
  

kubectl get pods
NAME                READY   STATUS    RESTARTS   AGE
flask-app-2-4-pod   1/1     Running   0          85s

kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   16h


Дававай пробросим порты, чтобы зайти на наш сервер
kubectl port-forward pod/flask-app-2-4-pod 8888:8888

kubectl port-forward pod/flask-app-2-4-pod 8888:8888
Forwarding from 127.0.0.1:8888 -> 8888
Forwarding from [::1]:8888 -> 8888
Handling connection for 8888
Handling connection for 8888

Страница выдаётся как и в задании 2.4, все работает.

kubectl logs flask-app-2-4-pod
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://localhost:8888
Press CTRL+C to quit
127.0.0.1 - - [26/Oct/2023 09:34:05] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [26/Oct/2023 09:34:05] "GET /favicon.ico HTTP/1.1" 404 -

Зайдём в под и посмотрим какие процессы запущены:
kubectl exec -it flask-app-2-4-pod /bin/bash

root@flask-app-2-4-pod:/app# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.4 106284 28376 ?        Ss   09:31   0:00 python3 app.py
root           9  0.0  0.0   4248  3640 pts/0    Ss   09:35   0:00 /bin/bash
root          18  0.0  0.0   5900  2956 pts/0    R+   09:35   0:00 ps aux

Работает наш flask app
Давайте теперь очистим pod и сервисы

kubectl delete pod flask-app-2-4-pod
pod "flask-app-2-4-pod" deleted

kubectl delete services kubernetes
service "kubernetes" deleted




