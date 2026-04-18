# Week 2 Lab - EBS Volume Setup Manual Instructions

This guide walks you through manually creating the Week 2 infrastructure in the AWS Console, including an EC2 instance with an additional EBS volume attached.

---

## Overview

You will create:
- 1 VPC
- 1 Public Subnet
- 1 Internet Gateway
- 1 Route Table
- 1 Security Group (ports 22 and 80)
- 1 EC2 Instance
- 1 Additional EBS Volume (20 GB)
- 1 Volume Attachment

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
7. **Note down the Subnet ID**

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
6. **Note down the Security Group ID**

---

## Step 6: Launch EC2 Instance

1. Go to **EC2 Dashboard** → Click **Launch Instance**
2. Configure:

   **Name and tags:**
   - **Name**: `Linux_Server`

   **Application and OS Images:**
   - Select **Amazon Linux 2023**
   - AMI ID: `ami-0b75f821522bcff85`

   **Instance type:**
   - Select **t2.micro**

   **Key pair:**
   - Select `Devops-Detroit-Linux-Workshop` from the dropdown
   - If it doesn't exist, click **Create new key pair**, name it `Devops-Detroit-Linux-Workshop`, and download the `.pem` file

   **Network settings** → Click **Edit**:
   - **VPC**: Select `Devops-Detroit-VPC`
   - **Subnet**: Select `Public_subnet` (us-east-1a)
   - **Auto-assign public IP**: Enable
   - **Firewall**: Select existing security group → Choose `EC2_Security_Group`

   **Storage:**
   - Leave default root volume (8 GB gp3)
   - > **Do not add the extra volume here** — we will create and attach it separately in the next steps

3. Click **Launch instance**
4. Wait for the instance state to show **Running**
5. **Note down the Instance ID and Public IP**

---

## Step 7: Create Additional EBS Volume

1. In **EC2 Dashboard** → Click **Volumes** under **Elastic Block Store**
2. Click **Create volume**
3. Configure:
   - **Volume type**: `gp3`
   - **Size**: `20` GiB
   - **Availability Zone**: `us-east-1a`

   > ⚠️ The volume **must** be in the same Availability Zone as your EC2 instance (`us-east-1a`)

   - **Encryption**: Check **Encrypt this volume**
   - **KMS key**: Leave default

   **Tags:**
   - **Key**: `Name`
   - **Value**: `Linux_Server-ebs`

4. Click **Create volume**
5. **Note down the Volume ID**

---

## Step 8: Attach EBS Volume to EC2 Instance

1. In **EC2 Dashboard** → Click **Volumes**
2. Select the `Linux_Server-ebs` volume you just created
3. Click **Actions** → **Attach volume**
4. Configure:
   - **Instance**: Select `Linux_Server`
   - **Device name**: `/dev/xvdf`
5. Click **Attach volume**
6. Wait for the volume state to change to **in-use**

---

## Step 9: Verify Your Setup

1. **Check VPC**: `Devops-Detroit-VPC` with CIDR `10.0.0.0/16`
2. **Check Subnet**: `Public_subnet` in `us-east-1a` with CIDR `10.0.0.0/24`
3. **Check Internet Gateway**: Attached to VPC
4. **Check Route Table**: Route `0.0.0.0/0` → IGW, associated with `Public_subnet`
5. **Check Security Group**: Inbound ports 22 and 80 open
6. **Check EC2**: Instance is **Running** with a public IP
7. **Check EBS Volume**: State is **in-use**, attached to `Linux_Server` at `/dev/xvdf`

---

## Step 10: Mount the EBS Volume on the Instance

After attaching the volume, SSH into your instance and mount it:

```bash
# Connect to your instance
ssh -i /path/to/Devops-Detroit-Linux-Workshop.pem ec2-user@<PUBLIC_IP>

# Check the volume is visible
lsblk

# Format the volume (first time only)
sudo mkfs -t ext4 /dev/xvdf

# Create a mount point
sudo mkdir /data

# Mount the volume
sudo mount /dev/xvdf /data

#Ensure that volume mount remains persitant through a reboot 

echo '/dev/xvdf /data ext4 defaults,nofail 0 0' | sudo tee -a /etc/fstab


#Check fstab entry

vi /etc/fstab

# Verify it is mounted
df -h

# Fill up usable space with a large file

fallocate -l 5G testfile


## Cleanup Instructions

Delete resources in this order p;l 
| EC2 t2.micro | Free tier: 750 hrs/month |
| EBS gp3 20GB | Free tier: 30 GB/month |
| VPC, Subnet, IGW | Free |

> **Free Tier eligible** as long as you stay within limits and clean up when done.

---

## Troubleshooting

**Volume not visible after attach (`lsblk` shows nothing)?**
- Confirm the volume is in the same AZ as the instance
- Check volume state is **in-use** in the console

**Can't format the volume?**
- Run `lsblk -f` to check if it already has a filesystem
- Skip `mkfs` if it does — go straight to mounting

**Can't connect via SSH?**
- Verify security group allows port 22
- Confirm instance has a public IP
- Check you are using the correct `.pem` key file
