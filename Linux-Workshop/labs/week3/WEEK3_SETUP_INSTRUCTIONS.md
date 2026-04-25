# Week 3 Lab - Nginx Web Server Setup Manual Instructions

This guide walks you through manually creating a Linux web server running Nginx on AWS EC2.

---

## Overview

You will create:
- 1 VPC
- 1 Public Subnet
- 1 Internet Gateway
- 1 Route Table
- 1 Security Group (ports 22 and 80)
- 1 EC2 Instance with Nginx installed via User Data
- 1 Custom HTML web page

---

## Step 1: Create a VPC

1. Go to **AWS Console** → Search for **VPC** and open the service
2. Click **Create VPC**
3. Configure:
   - **Name tag**: `Devops-Detroit-VPC`
   - **IPv4 CIDR block**: `10.0.0.0/16`
   - **IPv6 CIDR block**: No IPv6 CIDR block
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
4. Select the newly created subnet
5. Click **Actions** → **Modify auto-assign IP settings**
6. Check **Enable auto-assign public IPv4 address** → Click **Save**

---

## Step 3: Create an Internet Gateway

1. In **VPC Dashboard** → Click **Internet Gateways** → Click **Create internet gateway**
2. Configure:
   - **Name tag**: `Devops-Detroit-IGW`
3. Click **Create internet gateway**
4. Select the newly created IGW
5. Click **Actions** → **Attach to VPC** → Select `Devops-Detroit-VPC`
6. Click **Attach internet gateway**

---

## Step 4: Create and Configure Route Table

1. In **VPC Dashboard** → Click **Route Tables** → Click **Create route table**
2. Configure:
   - **Name**: `Public_RT`
   - **VPC**: Select `Devops-Detroit-VPC`
3. Click **Create route table**
4. Select the newly created route table
5. Go to **Routes** tab → Click **Edit routes** → Click **Add route**
   - **Destination**: `0.0.0.0/0`
   - **Target**: Select **Internet Gateway** → Choose your IGW
6. Click **Save changes**
7. Go to **Subnet associations** tab → Click **Edit subnet associations**
8. Select `Public_subnet` → Click **Save associations**

---

## Step 5: Create Security Group

1. In **VPC Dashboard** → Click **Security Groups** → Click **Create security group**
2. Configure:
   - **Security group name**: `EC2_Security_Group`
   - **Description**: `Allows SSH and HTTP traffic`
   - **VPC**: Select `Devops-Detroit-VPC`
3. **Inbound rules** → Click **Add rule** twice:

   **Rule 1 - SSH:**
   - **Type**: SSH
   - **Protocol**: TCP
   - **Port range**: `22`
   - **Source**: `0.0.0.0/0`

   **Rule 2 - HTTP:**
   - **Type**: HTTP
   - **Protocol**: TCP
   - **Port range**: `80`
   - **Source**: `0.0.0.0/0`

4. **Outbound rules**: Leave default (All traffic)
5. Click **Create security group**

---

## Step 6: Create User Data Script

The User Data script runs automatically when the instance first boots. It installs Nginx and deploys your HTML page.

1. Open a text editor on your local machine
2. Copy and paste the following script:

```bash
#!/bin/bash
apt update -y
apt install -y nginx

cat <<'EOF' > /var/www/html/index.nginx-debian.html

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevOps Detroit - Linux Workshop</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #232f3e;
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px;
            background-color: #37475a;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
        }
        h1 { color: #ff9900; }
        p  { font-size: 1.2em; }
        .badge {
            display: inline-block;
            background-color: #ff9900;
            color: #232f3e;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 DevOps Detroit</h1>
        <h2>Linux Workshop - Week 3</h2>
        <p>Your Nginx web server is up and running!</p>
        <p>Hosted on Amazon EC2</p>
        <div class="badge">Week 3 - Web Server Lab</div>
    </div>
</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx
```

3. Keep this script ready — you will paste it into the EC2 launch wizard in the next step

---

## Step 7: Launch EC2 Instance with User Data

1. Go to **EC2 Dashboard** → Click **Launch Instance**
2. Configure:

   **Name and tags:**
   - **Name**: `Linux_Web_Server`

   **Application and OS Images:**
   - Select **Amazon Linux 2023**
   - AMI ID: `ami-0b75f821522bcff85`

   **Instance type:**
   - Select **t2.micro**

   **Key pair:**
   - Select `Devops-Detroit-Linux-Workshop`
   - If it doesn't exist, click **Create new key pair**, name it `Devops-Detroit-Linux-Workshop`, and download the `.pem` file

   **Network settings** → Click **Edit**:
   - **VPC**: Select `Devops-Detroit-VPC`
   - **Subnet**: Select `Public_subnet` (us-east-1a)
   - **Auto-assign public IP**: Enable
   - **Firewall**: Select existing security group → Choose `EC2_Security_Group`

   **Storage:**
   - Leave default root volume (8 GB gp3)

   **Advanced details** → Scroll down to **User data**:
   - Paste the entire script from Step 6 into the text box

3. Click **Launch instance**
4. Wait for the instance state to show **Running**
5. **Note down the Instance ID and Public IP**

---

## Step 8: Verify the Web Server

1. Copy the **Public IP** of your `Linux_Web_Server` instance
2. Open a browser and navigate to:
   ```
   http://<PUBLIC_IP>
   ```
3. You should see the **DevOps Detroit - Linux Workshop Week 3** page

> ⚠️ Make sure you use `http://` not `https://` — port 443 is not configured

---

## Step 9: Verify via SSH (Optional)

```bash
# Connect to your instance
ssh -i /path/to/Devops-Detroit-Linux-Workshop.pem ec2-user@<PUBLIC_IP>

# Check nginx is running
sudo systemctl status nginx

# Verify the HTML file was created
cat /usr/share/nginx/html/index.html
```

---

## Cleanup Instructions

Delete resources in this order to avoid charges:

1. **Terminate EC2 instance**
3. **Delete Security Group**
4. **Delete Route Table** (custom one only)
5. **Detach and Delete Internet Gateway**
6. **Delete Subnet**
7. **Delete VPC**

---

## Troubleshooting

**Web page not loading in browser?**
- Wait 2-3 minutes after launch for User Data to finish running
- Confirm security group has port 80 open with source `0.0.0.0/0`
- Ensure you are using `http://` not `https://`
- Verify the instance has a public IP assigned

**Nginx not running after SSH?**
- Check User Data logs: `sudo cat /var/log/cloud-init-output.log`
- Manually install and start: `sudo yum install -y nginx && sudo systemctl start nginx`

**Can't connect via SSH?**
- Verify security group allows port 22
- Confirm you are using the correct `.pem` key file
- Check the instance has a public IP

