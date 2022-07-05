# Deploy UserManagement Web Application with MySQL Database

# Create Deployment & LoadBalancer Service
kubectl apply -f kube-manifests/


# List Pods
kubectl get pods


# Verify logs of Usermgmt Web Application Pod
kubectl logs -f <pod-name>


# If we have only 1 pod, below commnad works well for getting the logs
kubectl logs -f $(kubectl get po  | egrep -o 'usermgmt-webapp-[A-Za-z0-9-]+')


# Verify sc, pvc, pv
kubectl get sc,pvc,pv


- **Access Application**

# List Services
kubectl get svc


# Access Application
curl http://<External-IP-from-get-service-output>
#Username: admin101
#Password: password101


# Connect to MYSQL Database
kubectl run -it --rm --image=mysql:5.6 --restart=Never mysql-client -- mysql -h mysql -pdbpassword11


# Verify usermgmt schema got created which we provided in ConfigMap
mysql> show schemas;
mysql> use webappdb;
mysql> show tables;
mysql> select * from user;


## Step-06: Clean-Up
- Delete all k8s objects created as part of this section

# Delete All
kubectl delete -f kube-manifests/


# List Pods
kubectl get pods


# Verify sc, pvc, pv
kubectl get sc,pvc,pv


# Delete PV Exclusively
kubectl get pv


kubectl delete pv <PV-NAME>


- Delete Azure Disks
  - Go to All Services -> Disks -> Select and Delete the Disk
