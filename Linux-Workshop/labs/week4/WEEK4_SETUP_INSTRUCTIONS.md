# Week 4 Lab - DNS Failover Setup Manual Instructions

This guide walks you through manually creating a DNS failover setup using two EC2 web servers and Route 53.

---

## Overview

You will create:
- 1 VPC
- 1 Public Subnet
- 1 Internet Gateway
- 1 Route Table
- 1 Security Group (ports 22 and 80)
- 2 EC2 Instances (Primary and Secondary) with Nginx
- 2 Route 53 Health Checks
- 2 Route 53 Failover DNS Records

---

## Step 1: Create a VPC

1. Go to **AWS Console** → Search for **VPC** and open the service
2. Click **Create VPC**
3. Configure:
   - **Name tag**: `Devops-Detroit-VPC`
   - **IPv4 CIDR block**: `10.0.0.0/16`
   - **Tenancy**: Default
4. Click **Create VPC**
5. **Note down the VPC ID**

---

## Step 2: Create a Public Subnet

1. In **VPC Dashboard** → Click **Subnets** → Click **Create subnet**
2. Configure:
   - **VPC ID**: Select `Devops-Detroit-VPC`
   - **Subnet name**: `Public_subnet`
   - **Availability Zone**: `us-east-1a`
   - **IPv4 CIDR block**: `10.0.0.0/24`
3. Click **Create subnet**
4. Select the subnet → Click **Actions** → **Modify auto-assign IP settings**
5. Check **Enable auto-assign public IPv4 address** → Click **Save**

---

## Step 3: Create an Internet Gateway

1. In **VPC Dashboard** → Click **Internet Gateways** → Click **Create internet gateway**
2. **Name tag**: `Devops-Detroit-IGW`
3. Click **Create internet gateway**
4. Click **Actions** → **Attach to VPC** → Select `Devops-Detroit-VPC`
5. Click **Attach internet gateway**

---

## Step 4: Create and Configure Route Table

1. In **VPC Dashboard** → Click **Route Tables** → Click **Create route table**
2. Configure:
   - **Name**: `Public_RT`
   - **VPC**: Select `Devops-Detroit-VPC`
3. Click **Create route table**
4. Go to **Routes** tab → Click **Edit routes** → Click **Add route**
   - **Destination**: `0.0.0.0/0`
   - **Target**: Select your IGW
5. Click **Save changes**
6. Go to **Subnet associations** tab → Click **Edit subnet associations**
7. Select `Public_subnet` → Click **Save associations**

---

## Step 5: Create Security Group

1. In **VPC Dashboard** → Click **Security Groups** → Click **Create security group**
2. Configure:
   - **Security group name**: `week4-web-sg`
   - **Description**: `Allow SSH and HTTP`
   - **VPC**: Select `Devops-Detroit-VPC`
3. **Inbound rules** → Add two rules:

   **Rule 1 - SSH:**
   - **Type**: SSH | **Port**: `22` | **Source**: `0.0.0.0/0`

   **Rule 2 - HTTP:**
   - **Type**: HTTP | **Port**: `80` | **Source**: `0.0.0.0/0`

4. **Outbound rules**: Leave default (All traffic)
5. Click **Create security group**

---

## Step 6: Launch Primary EC2 Instance

1. Go to **EC2 Dashboard** → Click **Launch Instance**
2. Configure:

   **Name:** `Linux_Primary_Server`

   **AMI:** Amazon Linux 2023 — AMI ID: `ami-0b75f821522bcff85`

   **Instance type:** `t2.micro`

   **Key pair:** `Devops-Detroit-Linux-Workshop`

   **Network settings** → Click **Edit**:
   - **VPC**: `Devops-Detroit-VPC`
   - **Subnet**: `Public_subnet` (us-east-1a)
   - **Auto-assign public IP**: Enable
   - **Security group**: Select `week4-web-sg`

   **Advanced details** → **User data**, paste the following:

```bash
#!/bin/bash
yum update -y
yum install -y nginx

cat > /usr/share/nginx/html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Primary Server</title>
    <style>
        body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #1a5c38; color: white; }
        .container { text-align: center; padding: 40px; background-color: #217a4b; border-radius: 10px; }
        h1 { color: #a8f0c6; }
        .badge { display: inline-block; background-color: #a8f0c6; color: #1a5c38; padding: 8px 16px; border-radius: 20px; font-weight: bold; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🟢 PRIMARY SERVER</h1>
        <h2>DevOps Detroit - Linux Workshop</h2>
        <p>You are connected to the <strong>Primary</strong> server.</p>
        <p>Hosted on Amazon EC2 — us-east-1a</p>
        <div class="badge">Week 4 - DNS Failover Lab</div>
    </div>
</body>
</html>
HTMLEOF

systemctl enable nginx
systemctl start nginx
```

3. Click **Launch instance**
4. **Note down the Primary Public IP**

---

## Step 7: Launch Secondary EC2 Instance

1. Go to **EC2 Dashboard** → Click **Launch Instance**
2. Configure:

   **Name:** `Linux_Secondary_Server`

   **AMI:** Amazon Linux 2023 — AMI ID: `ami-0b75f821522bcff85`

   **Instance type:** `t2.micro`

   **Key pair:** `Devops-Detroit-Linux-Workshop`

   **Network settings** → Click **Edit**:
   - **VPC**: `Devops-Detroit-VPC`
   - **Subnet**: `Public_subnet` (us-east-1a)
   - **Auto-assign public IP**: Enable
   - **Security group**: Select `week4-web-sg`

   **Advanced details** → **User data**, paste the following:

```bash
#!/bin/bash
yum update -y
yum install -y nginx

cat > /usr/share/nginx/html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Secondary Server</title>
    <style>
        body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #1a3a5c; color: white; }
        .container { text-align: center; padding: 40px; background-color: #1e4d7a; border-radius: 10px; }
        h1 { color: #a8d4f0; }
        .badge { display: inline-block; background-color: #a8d4f0; color: #1a3a5c; padding: 8px 16px; border-radius: 20px; font-weight: bold; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔵 SECONDARY SERVER</h1>
        <h2>DevOps Detroit - Linux Workshop</h2>
        <p>You are connected to the <strong>Secondary</strong> server.</p>
        <p>Hosted on Amazon EC2 — us-east-1b</p>
        <div class="badge">Week 4 - DNS Failover Lab</div>
    </div>
</body>
</html>
HTMLEOF

systemctl enable nginx
systemctl start nginx
```

3. Click **Launch instance**
4. **Note down the Secondary Public IP**

---

## Step 8: Verify Both Web Servers

1. Open a browser and navigate to `http://<PRIMARY_PUBLIC_IP>`
   - You should see a **green** page with 🟢 PRIMARY SERVER
2. Open a browser and navigate to `http://<SECONDARY_PUBLIC_IP>`
   - You should see a **blue** page with 🔵 SECONDARY SERVER

> ⚠️ Use `http://` not `https://` — port 443 is not configured

---

## Step 9: Create Route 53 Health Checks

1. Go to **AWS Console** → Search for **Route 53** and open the service
2. In the left menu click **Health checks** → Click **Create health check**

   **Primary Health Check:**
   - **Name**: `primary-health-check`
   - **What to monitor**: Endpoint
   - **Protocol**: HTTP
   - **IP address**: `<PRIMARY_PUBLIC_IP>`
   - **Port**: `80`
   - **Path**: `/`
   - **Request interval**: 30 seconds
   - **Failure threshold**: 3
   - Click **Next** → Skip notifications → Click **Create health check**

3. Click **Create health check** again for the secondary:

   **Secondary Health Check:**
   - **Name**: `secondary-health-check`
   - **Protocol**: HTTP
   - **IP address**: `<SECONDARY_PUBLIC_IP>`
   - **Port**: `80`
   - **Path**: `/`
   - **Request interval**: 30 seconds
   - **Failure threshold**: 3
   - Click **Next** → Skip notifications → Click **Create health check**

4. Wait for both health checks to show status **Healthy**

---

## Step 10: Create Route 53 Failover Records

1. In **Route 53** → Click **Hosted zones**
2. Click on `devops-detroit-workshop.click`
3. Click **Create record**

   **Primary Failover Record:**
   - **Record name**: `www`
   - **Record type**: `A`
   - **Value**: `<PRIMARY_PUBLIC_IP>`
   - **TTL**: `60`
   - **Routing policy**: Failover
   - **Failover record type**: Primary
   - **Health check**: Select `primary-health-check`
   - **Record ID**: `primary`
   - Click **Create records**

4. Click **Create record** again for the secondary:

   **Secondary Failover Record:**
   - **Record name**: `www`
   - **Record type**: `A`
   - **Value**: `<SECONDARY_PUBLIC_IP>`
   - **TTL**: `60`
   - **Routing policy**: Failover
   - **Failover record type**: Secondary
   - **Health check**: Select `secondary-health-check`
   - **Record ID**: `secondary`
   - Click **Create records**

---

## Step 11: Test DNS Failover

1. Open a browser and navigate to `http://www.devops-detroit-workshop.click`
   - You should see the **green** Primary Server page
2. To simulate failover, stop the **primary** EC2 instance:
   - Go to **EC2 Dashboard** → Select `Linux_Primary_Server`
   - Click **Instance state** → **Stop instance**
3. Wait 1-2 minutes for the health check to detect the failure
4. Refresh `http://www.devops-detroit-workshop.click`
   - You should now see the **blue** Secondary Server page
5. Restart the primary instance to restore normal routing

---

## Cleanup Instructions

Delete resources in this order to avoid charges:

1. **Delete Route 53 failover records**
2. **Delete Route 53 health checks**
3. **Terminate both EC2 instances**
4. **Delete Security Group**
5. **Delete Route Table**
6. **Detach and Delete Internet Gateway**
7. **Delete Subnet**
8. **Delete VPC**

---

## Troubleshooting

**Health check showing Unhealthy?**
- Wait 2-3 minutes after launch for nginx to finish installing
- Verify security group allows port 80 from `0.0.0.0/0`
- Confirm instance has a public IP and is in Running state
- Check nginx is running: `sudo systemctl status nginx`

**Failover not switching?**
- Confirm the primary health check status is **Unhealthy** in Route 53
- TTL is set to 60 seconds — allow up to 2 minutes for DNS to propagate

**Web page not loading?**
- Use `http://` not `https://`
- Check User Data logs: `sudo cat /var/log/cloud-init-output.log`
