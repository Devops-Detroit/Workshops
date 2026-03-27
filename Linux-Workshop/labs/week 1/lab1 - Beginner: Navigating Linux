# Lab 1: Connecting to Linux with SSH and Basic Command Practice

## Lab Goal
In this lab, learners will:
- Connect to a Linux machine using SSH
- Practice moving around directories with `cd`
- View file contents with `cat`
- Edit a file with `nano`
- Start and reattach a terminal session using `screen`
- Disconnect from Linux with `exit`

## Estimated Time
30-45 minutes

## Prerequisites
- A running Linux machine (cloud VM, local VM, or lab instance)
- SSH access information:
	- Public IP or hostname
	- Username (for example: `ubuntu`, `ec2-user`, or `student`)
	- SSH private key file (if key-based login is required)
- A terminal application on your computer

## Scenario
You are a junior administrator logging into a Linux server for the first time. Your job is to connect, explore directories, create and edit a notes file, run work inside `screen`, and safely disconnect.

---

## Step 1: Connect to the Linux Machine with SSH

From your local computer terminal, run one of the following:

### Key-based authentication
```bash
ssh -i /path/to/private-key.pem username@SERVER_IP
```

### Password authentication
```bash
ssh username@SERVER_IP
```

If prompted, type `yes` to trust the host key.

### Success Check
You should see a Linux command prompt, similar to:
```bash
username@hostname:~$
```

---

## Step 2: Navigate with `cd`

Run these commands:
```bash
cd /
cd /home
cd ~
```

What happened:
- `cd /` moves to the root directory
- `cd /home` moves to the home parent directory
- `cd ~` returns to your user home directory

### Challenge
Create and enter a lab directory:
```bash
mkdir -p ~/lab1
cd ~/lab1
```

---

## Step 3: View File Content with `cat`

Create a simple file and read it:
```bash
echo "Welcome to Linux Lab 1" > notes.txt
cat notes.txt
```

### Success Check
The output should show:
```text
Welcome to Linux Lab 1
```

---

## Step 4: Edit a File with `nano`

Open the file:
```bash
nano notes.txt
```

Inside nano:
- Add a new line: `Practiced cd and cat`
- Save with `Ctrl+O`, then press Enter
- Exit nano with `Ctrl+X`

Verify your changes:
```bash
cat notes.txt
```

### Success Check
You should see two lines in the file.

---

## Step 5: Use `screen` for Persistent Sessions

Start a new screen session named `lab1`:
```bash
screen -S lab1
```

Now you are inside a screen session. Create a quick message file:
```bash
echo "Running inside screen session" > screen-note.txt
cat screen-note.txt
```

Detach from screen (without ending it):
- Press `Ctrl+A`, then press `D`

List available screen sessions:
```bash
screen -ls
```

Reattach to your session:
```bash
screen -r lab1
```

When done, exit the screen session by typing:
```bash
exit
```

---

## Step 6: Disconnect from the Linux Machine with `exit`

At the Linux shell prompt, run:
```bash
exit
```

### Success Check
You should return to your local computer prompt.

---

## Lab Validation Checklist
- [ ] I connected to a Linux machine using SSH
- [ ] I used `cd` to move between directories
- [ ] I used `cat` to read file contents
- [ ] I edited and saved a file with `nano`
- [ ] I started, detached, and reattached a `screen` session
- [ ] I used `exit` to disconnect cleanly

## Optional Extension
If time remains, repeat the lab without copying commands. Explain what each command does before running it.
