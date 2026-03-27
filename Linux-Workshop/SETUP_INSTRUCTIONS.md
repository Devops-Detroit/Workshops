# AWS Infrastructure Setup - Manual Instructions

This guide provides step-by-step instructions to manually create the infrastructure defined in `main.tf` using the AWS Console.

---

## Before You Begin: Create an AWS Account

> Skip this section if you already have an AWS account.

### Step 0a: Sign Up for AWS

1. Go to [https://aws.amazon.com](https://aws.amazon.com)
2. Click **Create an AWS Account**
3. Enter your **email address** and choose an **AWS account name**
4. Click **Verify email address** and enter the verification code sent to your email
5. Create a **root user password** and click **Continue**

### Step 0b: Enter Contact Information

1. Select **Personal** or **Business** account type
2. Fill in your full name, phone number, and address
3. Read and accept the **AWS Customer Agreement**
4. Click **Continue**

### Step 0c: Add a Payment Method

1. Enter a valid **credit or debit card**
2. AWS will place a small temporary authorization hold (~$1) to verify the card
3. Click **Verify and Continue**

> **Note**: This workshop uses free tier eligible resources. You will not be charged if you stay within free tier limits and clean up resources when done.

### Step 0d: Verify Your Identity

1. Choose **Text message (SMS)** or **Voice call**
2. Enter your phone number and click **Send SMS**
3. Enter the verification code received
4. Click **Continue**

### Step 0e: Choose a Support Plan

1. Select **Basic support - Free**
2. Click **Complete sign up**
3. You will see a confirmation page — your account may take a few minutes to activate
4. You will receive a confirmation email when your account is ready

### Step 0f: Sign In to the AWS Console

1. Go to [https://console.aws.amazon.com](https://console.aws.amazon.com)
2. Click **Sign in as Root User**
3. Enter your email and password
4. You are now in the AWS Management Console

> **Security Tip**: After signing in, set up **Multi-Factor Authentication (MFA)** on your root account:
> - Go to **IAM** → **Dashboard** → **Add MFA for root user**
> - Follow the prompts to link an authenticator app (e.g. Google Authenticator)

---

## Overview

You will create:
- 1 VPC with custom CIDR block
- 1 Public Subnet
- 1 Internet Gateway
- 1 Route Table
- 1 EC2 Instance (Linux Server)
- 1 Security Group

---

## Step 1: Create a VPC

1. Go to **AWS Console** → **VPC** service
2. Click **Create VPC**
3. Configure:
   - **Name tag**: `Devops-Detroit-VPC`
   - **IPv4 CIDR block**: `10.0.0.0/16`
   - **IPv6 CIDR block**: No IPv6 CIDR block
   - **Tenancy**: Default
4. Click **Create VPC**
5. **Note down the VPC ID** (you'll need it later)

---

## Step 2: Create a Public Subnet

1. In **VPC Dashboard** → Click **Subnets**
2. Click **Create subnet**
3. Configure:
   - **VPC ID**: Select `Devops-Detroit-VPC`
   - **Subnet name**: `Public-Subnet`
   - **Availability Zone**: `us-east-1a`
   - **IPv4 CIDR block**: `10.0.1.0/24`
4. Click **Create subnet**
5. Select the newly created subnet
6. Click **Actions** → **Modify auto-assign IP settings**
7. Check **Enable auto-assign public IPv4 address**
8. Click **Save**
9. **Note down the Subnet ID**

---

## Step 3: Create an Internet Gateway

1. In **VPC Dashboard** → Click **Internet Gateways**
2. Click **Create internet gateway**
3. Configure:
   - **Name tag**: `Devops-Detroit-IGW`
4. Click **Create internet gateway**
5. Select the newly created IGW
6. Click **Actions** → **Attach to VPC**
7. Select `Devops-Detroit-VPC`
8. Click **Attach internet gateway**

---

## Step 4: Create and Configure Route Table

1. In **VPC Dashboard** → Click **Route Tables**
2. Click **Create route table**
3. Configure:
   - **Name**: `Public-Route-Table`
   - **VPC**: Select `Devops-Detroit-VPC`
4. Click **Create route table**
5. Select the newly created route table
6. Go to **Routes** tab → Click **Edit routes**
7. Click **Add route**
   - **Destination**: `0.0.0.0/0`
   - **Target**: Select **Internet Gateway** → Choose your IGW
8. Click **Save changes**
9. Go to **Subnet associations** tab → Click **Edit subnet associations**
10. Select your **Public-Subnet**
11. Click **Save associations**

---

## Step 5: Create Security Group

1. In **VPC Dashboard** → Click **Security Groups**
2. Click **Create security group**
3. Configure:
   - **Security group name**: `Linux-Server-SG`
   - **Description**: `Security group for Linux Server`
   - **VPC**: Select `Devops-Detroit-VPC`
4. **Inbound rules** → Click **Add rule** (twice):

   **Rule 1:**
   - **Type**: SSH
   - **Protocol**: TCP
   - **Port range**: 22
   - **Source**: `0.0.0.0/0` (or your IP for better security)

   **Rule 2:**
   - **Type**: HTTP
   - **Protocol**: TCP
   - **Port range**: 80
   - **Source**: `0.0.0.0/0`

5. **Outbound rules**: Leave default (All traffic)
6. Click **Create security group**
7. **Note down the Security Group ID**

---

## Step 6: Launch EC2 Instance

1. Go to **EC2 Dashboard** → Click **Launch Instance**
2. Configure:

   **Name and tags:**
   - **Name**: `Linux_Server`

   **Application and OS Images:**
   - Choose **Amazon Linux 2023** (or your preferred Linux AMI)

   **Instance type:**
   - Select **t2.micro** (free tier eligible)

   **Key pair:**
   - Select existing key pair or create new one
   - **Important**: Download and save the .pem file securely

   **Network settings:**
   - Click **Edit**
   - **VPC**: Select `Devops-Detroit-VPC`
   - **Subnet**: Select your `Public-Subnet` (us-east-1a)
   - **Auto-assign public IP**: Enable
   - **Firewall (security groups)**: Select existing security group
   - Choose `Linux-Server-SG`

   **Storage:**
   - Leave default (8 GB gp3)

3. Click **Launch instance**
4. Wait for instance state to show **Running**
5. **Note down the Public IP address**

---

## Step 7: Verify Your Setup

1. **Check VPC**: Ensure `Devops-Detroit-VPC` exists with CIDR `10.0.0.0/16`
2. **Check Subnet**: Verify public subnet in `us-east-1a`
3. **Check Internet Gateway**: Confirm attached to VPC
4. **Check Route Table**: Verify route to `0.0.0.0/0` via IGW
5. **Check Security Group**: Confirm ports 22 and 80 are open
6. **Check EC2**: Instance should be running with public IP

---

## Step 8: Connect to Your Linux Server

**Using SSH (from your local machine):**

```bash
ssh -i /path/to/your-key.pem ec2-user@<PUBLIC_IP_ADDRESS>
```

**Windows users can use:**
- PuTTY (convert .pem to .ppk first)
- Windows PowerShell
- AWS Systems Manager Session Manager

---

## Cleanup Instructions

When you're done testing, delete resources in this order to avoid charges:

1. **Terminate EC2 Instance**
2. **Delete Security Group**
3. **Delete Route Table** (custom one only)
4. **Detach and Delete Internet Gateway**
5. **Delete Subnet**
6. **Delete VPC**

---

## Cost Considerations

- **EC2 t2.micro**: ~$0.0116/hour (free tier: 750 hours/month)
- **VPC, Subnets, IGW**: Free
- **Data transfer**: First 100 GB/month free outbound

**Estimated monthly cost**: ~$8.50 (if running 24/7 after free tier)

---

## Troubleshooting

**Can't connect via SSH?**
- Verify security group allows port 22 from your IP
- Check instance has public IP assigned
- Verify route table has route to IGW
- Ensure correct key pair is being used

**Instance has no internet access?**
- Verify Internet Gateway is attached
- Check route table has `0.0.0.0/0` → IGW route
- Confirm subnet is associated with correct route table

---

## Notes

- Region: **us-east-1** (N. Virginia)
- All resources should be created in the same region
- Keep your SSH key (.pem file) secure and never share it
- For production, restrict SSH access to specific IP addresses only
