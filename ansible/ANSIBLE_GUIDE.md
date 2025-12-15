# 🚀 Ansible Configuration Management Guide

Complete guide to use Ansible for automated configuration and deployment of the Todo application.

---

## 📋 What Was Created

```
ansible/
├── hosts.ini           # Inventory file (defines target hosts)
├── playbook.yaml       # Main configuration playbook
├── deploy-app.yaml     # Application deployment playbook
└── k8s/
    ├── configmap.yaml  # Database & app configuration
    ├── deployment.yaml # Kubernetes deployments (app + Redis)
    └── service.yaml    # Kubernetes services (LoadBalancer + ClusterIP)
```

---

## 🎯 What Ansible Does

### **playbook.yaml** (Configuration Management)
- Configures kubectl on your local machine
- Connects to your EKS cluster
- Creates Kubernetes namespace
- Prepares environment for deployment

### **deploy-app.yaml** (Application Deployment)
- Deploys ConfigMap and Secrets
- Deploys Todo App (2 replicas)
- Deploys Redis cache
- Creates LoadBalancer service
- Displays application URL

---

## 🔧 Prerequisites

### **1. Install Ansible**

**Windows (using pip):**
```powershell
pip install ansible
```

**Verify installation:**
```powershell
ansible --version
```

### **2. Install kubectl** (if not already installed)

Download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

Or use chocolatey:
```powershell
choco install kubernetes-cli
```

### **3. Configure AWS CLI**
Already done in Step 2!

---

## 🚀 Step-by-Step Execution

### **Step 1: Navigate to Project Directory**

```powershell
cd D:\sem7\Devops\midLabExam\mysql-spring-boot-todo
```

### **Step 2: Update RDS Endpoint in ConfigMap**

Edit `ansible/k8s/configmap.yaml`:

Replace the database URL with your actual RDS endpoint from terraform output:

```powershell
cd infra
terraform output rds_endpoint
cd ..
```

Copy the endpoint and update in `ansible/k8s/configmap.yaml`:
```yaml
SPRING_DATASOURCE_URL: "jdbc:mysql://YOUR-RDS-ENDPOINT:3306/tododb?useSSL=false&allowPublicKeyRetrieval=true"
```

### **Step 3: Run Main Configuration Playbook**

```powershell
cd ansible
ansible-playbook -i hosts.ini playbook.yaml
```

**Expected Output:**
```
PLAY [Configure Local Environment for Kubernetes Deployment] ****

TASK [Display playbook start message] ****************************
ok: [localhost]

TASK [Check if kubectl is installed] *****************************
ok: [localhost]

TASK [Configure kubectl for EKS cluster] *************************
changed: [localhost]

TASK [Create namespace for todo app] *****************************
changed: [localhost]

PLAY RECAP *******************************************************
localhost : ok=8 changed=2 unreachable=0 failed=0
```

**📸 SCREENSHOT THIS OUTPUT!**

---

### **Step 4: Deploy Application**

```powershell
ansible-playbook -i hosts.ini deploy-app.yaml
```

**Expected Output:**
```
PLAY [Deploy Todo Application to Kubernetes] *********************

TASK [Deploy Redis and Todo App] *********************************
changed: [localhost]

TASK [Create Services (LoadBalancer and ClusterIP)] **************
changed: [localhost]

TASK [Wait for deployments to be ready] **************************
ok: [localhost] => (item=redis)
ok: [localhost] => (item=todo-app)

TASK [Display application access information] ********************
ok: [localhost] => {
    "msg": [
        "================================================",
        "Todo App Deployment Complete!",
        "================================================",
        "LoadBalancer URL: a1b2c3-123456.us-east-1.elb.amazonaws.com",
        "Access your app at: http://a1b2c3-123456.us-east-1.elb.amazonaws.com",
        "================================================"
    ]
}

PLAY RECAP *******************************************************
localhost : ok=12 changed=3 unreachable=0 failed=0
```

**📸 SCREENSHOT THIS OUTPUT!**

---

## ✅ Verification

### **Check Pods are Running**

```powershell
kubectl get pods -n todo-app
```

**Expected:**
```
NAME                        READY   STATUS    RESTARTS   AGE
redis-xxx                   1/1     Running   0          2m
todo-app-xxx                1/1     Running   0          2m
todo-app-yyy                1/1     Running   0          2m
```

### **Check Services**

```powershell
kubectl get svc -n todo-app
```

**Expected:**
```
NAME                TYPE           EXTERNAL-IP                      PORT(S)
redis-service       ClusterIP      10.100.x.x                       6379/TCP
todo-app-service    LoadBalancer   a1b2-xxx.us-east-1.elb.aws.com   80:xxxxx/TCP
```

### **Access Application**

Wait 2-3 minutes for LoadBalancer to be ready, then:

```powershell
kubectl get svc todo-app-service -n todo-app
```

Copy the EXTERNAL-IP and open in browser:
```
http://EXTERNAL-IP
```

---

## 📸 Required Screenshots

1. ✅ **Ansible playbook.yaml execution** - Show successful run
2. ✅ **Ansible deploy-app.yaml execution** - Show deployment complete
3. ✅ **kubectl get pods** - Show running pods
4. ✅ **Browser** - Access the application via LoadBalancer URL

---

## 🧹 Cleanup

### **Delete Kubernetes Resources**

```powershell
kubectl delete namespace todo-app
```

### **Destroy Terraform Infrastructure**

```powershell
cd ..\infra
terraform destroy
```

---

## 🔍 Troubleshooting

### **Error: kubectl not found**

Install kubectl:
```powershell
choco install kubernetes-cli
```

### **Error: Unable to connect to cluster**

Reconfigure kubectl:
```powershell
aws eks update-kubeconfig --region us-east-1 --name todo-app-cluster
```

### **Error: Pods not starting**

Check pod logs:
```powershell
kubectl logs -n todo-app <pod-name>
```

Check events:
```powershell
kubectl get events -n todo-app
```

### **Error: LoadBalancer pending**

Wait 3-5 minutes for AWS to provision the LoadBalancer. Check status:
```powershell
kubectl describe svc todo-app-service -n todo-app
```

---

## 📚 What You Demonstrated

✅ **Ansible Playbooks**: Automated configuration  
✅ **Inventory Management**: hosts.ini file  
✅ **Idempotent Operations**: Safe to run multiple times  
✅ **Kubernetes Deployment**: Automated app deployment  
✅ **Configuration Management**: ConfigMaps and Secrets  
✅ **Service Discovery**: LoadBalancer provisioning  

---

## 💡 Key Ansible Features Used

- **Hosts & Inventory**: Target machine definition
- **Tasks**: Individual automation steps
- **Modules**: `command`, `shell`, `debug`
- **Conditionals**: `when`, `failed_when`, `changed_when`
- **Loops**: Deploy multiple resources
- **Variables**: Reusable configuration
- **Idempotency**: Safe repeated execution

---

**Ready to run? Start with Step 1!** 🚀
