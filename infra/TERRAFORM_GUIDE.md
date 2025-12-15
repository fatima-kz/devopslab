# 🚀 Terraform AWS Infrastructure Guide

Complete guide to provision AWS infrastructure for the Todo application using Terraform.

---

## 📋 What Will Be Created

This Terraform configuration will provision:

### **Network Infrastructure:**
- ✅ VPC (10.0.0.0/16)
- ✅ 2 Public Subnets (for load balancers)
- ✅ 2 Private Subnets (for app & database)
- ✅ Internet Gateway
- ✅ NAT Gateway
- ✅ Route Tables

### **Compute Infrastructure:**
- ✅ EKS Cluster (Kubernetes 1.28)
- ✅ EKS Node Group (2 t3.small instances)
- ✅ IAM Roles & Policies

### **Database Infrastructure:**
- ✅ RDS MySQL 5.7 (db.t3.micro)
- ✅ DB Subnet Group
- ✅ Security Groups

### **Security:**
- ✅ Security Groups for EKS, RDS, ALB
- ✅ Encrypted RDS storage
- ✅ Private subnet for database

---

## 💰 Estimated Costs

| Resource | Cost (per hour) | Monthly Estimate |
|----------|----------------|------------------|
| EKS Cluster | $0.10/hr | $72/month |
| 2x t3.small nodes | $0.04/hr | $29/month |
| RDS t3.micro | $0.017/hr | $12/month |
| NAT Gateway | $0.045/hr | $32/month |
| **TOTAL** | **~$0.20/hr** | **~$145/month** |

**⚠️ IMPORTANT:** Run `terraform destroy` after taking screenshots to avoid charges!

---

## 🚀 Step-by-Step Deployment

### **Step 1: Navigate to infra Directory**

```powershell
cd infra
```

### **Step 2: Update terraform.tfvars (Optional)**

Edit `terraform.tfvars` if you want to change the database password:

```powershell
notepad terraform.tfvars
```

Change the `db_password` to something secure.

### **Step 3: Initialize Terraform**

```powershell
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### **Step 4: Validate Configuration**

```powershell
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

### **Step 5: Plan Infrastructure**

```powershell
terraform plan
```

This shows what will be created. Review the output carefully.

**Expected Output:**
```
Plan: 45 to add, 0 to change, 0 to destroy.
```

### **Step 6: Apply Configuration (CREATE RESOURCES)**

```powershell
terraform apply
```

Type `yes` when prompted.

**⏱️ Time:** This will take **15-20 minutes** (EKS cluster takes longest)

**Expected Output:**
```
Apply complete! Resources: 45 added, 0 changed, 0 destroyed.

Outputs:

database_connection_string = <sensitive>
eks_cluster_endpoint = "https://ABC123.eks.us-east-1.amazonaws.com"
eks_cluster_name = "todo-app-cluster"
kubectl_config_command = "aws eks update-kubeconfig --region us-east-1 --name todo-app-cluster"
rds_endpoint = "todo-app-mysql.abc123.us-east-1.rds.amazonaws.com:3306"
vpc_id = "vpc-0abc123def456"
```

---

## 📊 View Outputs

### **Show All Outputs**

```powershell
terraform output
```

### **Show Specific Output**

```powershell
# RDS endpoint
terraform output rds_endpoint

# EKS cluster name
terraform output eks_cluster_name

# Database connection string
terraform output database_connection_string
```

### **Show Sensitive Outputs**

```powershell
terraform output -json | ConvertFrom-Json
```

---

## 📸 Required Screenshots for Assignment

### **Screenshot 1: Terraform Output**

```powershell
terraform output
```

Take a screenshot showing all outputs.

---

### **Screenshot 2: AWS VPC Console**

1. Go to: https://console.aws.amazon.com/vpc/
2. Region: **US East (N. Virginia)**
3. Click **"Your VPCs"**
4. Screenshot showing the `todo-app-vpc`
5. Click **"Subnets"**
6. Screenshot showing 4 subnets (2 public, 2 private)

---

### **Screenshot 3: AWS EKS Console**

1. Go to: https://console.aws.amazon.com/eks/
2. Region: **US East (N. Virginia)**
3. Click on cluster: `todo-app-cluster`
4. Screenshot showing:
   - Cluster status: **Active**
   - Endpoint URL
   - Kubernetes version: 1.28

5. Click **"Compute"** tab
6. Screenshot showing node group with 2 nodes

---

### **Screenshot 4: AWS RDS Console**

1. Go to: https://console.aws.amazon.com/rds/
2. Region: **US East (N. Virginia)**
3. Click **"Databases"**
4. Click on database: `todo-app-mysql`
5. Screenshot showing:
   - Status: **Available**
   - Engine: MySQL 5.7
   - Endpoint address
   - VPC and subnets

---

### **Screenshot 5: AWS Security Groups**

1. Go to: https://console.aws.amazon.com/ec2/
2. Click **"Security Groups"** in left sidebar
3. Screenshot showing security groups:
   - `todo-app-eks-cluster-sg`
   - `todo-app-eks-nodes-sg`
   - `todo-app-rds-sg`
   - `todo-app-alb-sg`

---

## 🧹 Cleanup (DESTROY RESOURCES)

**⚠️ CRITICAL:** Do this AFTER taking all screenshots to avoid charges!

### **Step 1: Destroy Infrastructure**

```powershell
terraform destroy
```

Type `yes` when prompted.

**⏱️ Time:** 10-15 minutes

**Expected Output:**
```
Destroy complete! Resources: 45 destroyed.
```

### **Step 2: Screenshot Terraform Destroy**

Take a screenshot of the terminal showing `Destroy complete!`

---

### **Step 3: Verify in AWS Console**

Go back to AWS Console and verify:
- ✅ VPC deleted
- ✅ EKS cluster deleted
- ✅ RDS database deleted
- ✅ Security groups deleted (except default)

---

## 🔧 Troubleshooting

### **Error: Invalid credentials**

```powershell
aws configure
# Re-enter your credentials
```

### **Error: Region not supported**

Edit `terraform.tfvars`:
```hcl
aws_region = "us-east-1"  # Make sure this is correct
```

### **Error: Insufficient capacity**

Change instance type in `terraform.tfvars`:
```hcl
eks_node_instance_type = "t3.medium"  # Instead of t3.small
```

### **Error: Quota exceeded**

Request quota increase in AWS Console or use smaller configuration:
```hcl
eks_desired_size = 1  # Instead of 2
```

### **Destroy fails**

```powershell
# Manually delete resources in AWS Console first, then:
terraform destroy -auto-approve
```

---

## 📝 Files Created

```
infra/
├── main.tf          # Provider configuration
├── variables.tf     # Variable definitions
├── terraform.tfvars # Variable values (GITIGNORE THIS!)
├── vpc.tf           # VPC, subnets, networking
├── security.tf      # Security groups
├── eks.tf           # EKS cluster and node groups
├── rds.tf           # RDS MySQL database
└── outputs.tf       # Output values
```

---

## 🔐 Security Best Practices

1. **Never commit `terraform.tfvars`** (contains passwords)
2. **Never commit `terraform.tfstate`** (contains sensitive data)
3. **Use strong database passwords**
4. **Destroy resources when not in use**
5. **Enable MFA on AWS account**

---

## 📚 Next Steps (After Screenshots)

### **Configure kubectl**

```powershell
# Get the command from terraform output
terraform output kubectl_config_command

# Run it
aws eks update-kubeconfig --region us-east-1 --name todo-app-cluster

# Verify
kubectl get nodes
```

### **Update Application to Use RDS**

Get the RDS endpoint:
```powershell
terraform output rds_endpoint
```

Update your Kubernetes deployment to use this endpoint instead of local MySQL.

---

## ✅ Submission Checklist

- [ ] Terraform files in `infra/` folder
- [ ] Screenshot: `terraform output` command
- [ ] Screenshot: AWS VPC Console
- [ ] Screenshot: AWS EKS Console (cluster + nodes)
- [ ] Screenshot: AWS RDS Console
- [ ] Screenshot: AWS Security Groups
- [ ] Screenshot: `terraform destroy` completion
- [ ] Verify all resources deleted in AWS Console

---

## 💡 Tips

- **Monitor costs:** Check AWS Billing Dashboard regularly
- **Set billing alerts:** Configure alerts for spending > $10
- **Use free tier:** RDS free tier = 750 hours/month of db.t2.micro (not t3.micro)
- **Destroy quickly:** Don't keep resources running overnight

---

**Need Help?** Check the troubleshooting section or AWS documentation.
