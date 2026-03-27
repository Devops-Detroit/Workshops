# Lab 2 (Intermediate): Set Up a Web Server on Debian 12 (AWS)

## Lab Goal
In this lab, you will:
- Launch or use an existing Debian 12 EC2 instance on AWS
- Allow web traffic on port 80
- Install Nginx
- Create a basic HTML page
- View the page in a browser over HTTP

## Estimated Time
30-45 minutes

## Prerequisites
- AWS account access
- An EC2 instance running Debian 12
- SSH key pair (`.pem`) that matches your EC2 instance
- Public IPv4 address or public DNS name of the instance
- A terminal on your local machine

---

## Architecture Overview
Your browser -> AWS Security Group (port 80 open) -> Debian 12 EC2 -> Nginx -> HTML file in `/var/www/html`

---

## Step 1: Verify AWS Security Group Rules

1. Open AWS Console -> EC2 -> Instances.
2. Select your Debian 12 instance.
3. Open the instance Security tab and click the attached security group.
4. Ensure inbound rules include:
	- SSH: TCP 22 from your IP (recommended)
	- HTTP: TCP 80 from `0.0.0.0/0` (and `::/0` if using IPv6)

### Success Check
You can see an inbound HTTP rule for TCP port 80.

---

## Step 2: Connect to Debian 12 via SSH

From your local terminal, run:

```bash
ssh -i /path/to/your-key.pem admin@EC2_PUBLIC_IP
```

Notes:
- Some Debian AMIs use `admin` as the default user.
- If `admin` fails, try `debian`.

If prompted to trust the host, type `yes`.

### Success Check
You should land at a Debian shell prompt.

---

## Step 3: Update Packages and Install Nginx

Run:

```bash
sudo apt update
sudo apt install -y nginx
```

Confirm Nginx service status:

```bash
sudo systemctl status nginx --no-pager
```

You can also verify it is enabled to start on boot:

```bash
sudo systemctl enable nginx
```

### Success Check
`systemctl status` shows Nginx as `active (running)`.

---

## Step 4: Create a Basic HTML File

Replace the default web page with your own:

```bash
sudo tee /var/www/html/index.html > /dev/null <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Debian 12 on AWS</title>
</head>
<body>
  <h1>It works!</h1>
  <p>Nginx is running on Debian 12 in AWS.</p>
</body>
</html>
EOF
```

Check file contents:

```bash
cat /var/www/html/index.html
```

### Success Check
You can see your custom HTML content in the file output.

---

## Step 5: Validate Locally on the Instance

Run:

```bash
curl http://localhost
```

### Success Check
The command output includes `It works!`.

---

## Step 6: View the Page from Your Browser (Port 80)

On your local machine, open:

```text
http://EC2_PUBLIC_IP
```

or

```text
http://EC2_PUBLIC_DNS
```

### Success Check
Your browser displays:
- `It works!`
- `Nginx is running on Debian 12 in AWS.`

---

## Troubleshooting

If the page does not load:

1. Confirm security group has inbound TCP 80 open.
2. Check Nginx is running:
	```bash
	sudo systemctl status nginx --no-pager
	```
3. Check Nginx is listening on port 80:
	```bash
	sudo ss -tulnp | grep :80
	```
4. Test on the instance first:
	```bash
	curl http://localhost
	```
5. Confirm you are browsing to the correct public IP/DNS.

---

## Lab Validation Checklist
- [ ] I confirmed AWS security group allows HTTP on port 80
- [ ] I connected to Debian 12 over SSH
- [ ] I installed Nginx successfully
- [ ] I created a custom `/var/www/html/index.html`
- [ ] I verified the page with `curl http://localhost`
- [ ] I viewed the page in a browser using the EC2 public address

## Optional Extension 1
Change the HTML page title and heading, refresh the browser, and confirm your update appears immediately.

## Optional Extension 2: HTTPS with Certbot (Port 443)

Use this extension to secure your site with a free TLS certificate from Let's Encrypt.

### Important Requirement
You must have a real domain name that points to your EC2 public IP (for example, `www.example.com`).
Let's Encrypt cannot issue a certificate for raw IP addresses.

### Step A: Open HTTPS in AWS Security Group
In your EC2 security group inbound rules, add:
- HTTPS: TCP 443 from `0.0.0.0/0` (and `::/0` if using IPv6)

### Step B: Point DNS to the EC2 Instance
At your DNS provider (or Route 53), create an `A` record:
- Host: your domain (for example, `www.example.com`)
- Value: EC2 public IPv4 address

Confirm DNS resolves:
```bash
dig +short www.example.com
```

### Step C: Install Certbot and Nginx Plugin
On Debian 12:
```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
```

### Step D: Request and Configure the Certificate
Run Certbot with your domain:
```bash
sudo certbot --nginx -d www.example.com
```

During prompts:
- Enter an email address
- Accept terms of service
- Choose whether to share email with EFF
- Select the option to redirect HTTP to HTTPS when asked

### Step E: Verify HTTPS on Port 443
Check Nginx is listening on 443:
```bash
sudo ss -tulnp | grep :443
```

Open in browser:
```text
https://www.example.com
```

### Step F: Confirm Automatic Renewal
Test renewal process:
```bash
sudo certbot renew --dry-run
```

### Success Check
- Your site loads over `https://`
- Browser shows a valid lock icon
- `certbot renew --dry-run` completes without errors
