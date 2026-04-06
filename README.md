# 🛰️ DNS Sweeper

> Fast & lightweight DNS enumeration tool written in Bash.

![bash](https://img.shields.io/badge/language-bash-green)
![status](https://img.shields.io/badge/status-active-success)
![license](https://img.shields.io/badge/license-MIT-blue)

---

## ✨ Overview

**DNS Sweeper** is a simple yet powerful tool designed to perform **DNS reconnaissance and enumeration** directly from the terminal.

Built for speed and clarity, it provides essential DNS insights with a clean, colorized output — perfect for pentesters, students, and cybersecurity enthusiasts.

---

## 🚀 Features

* 🔎 IPv4 (A) resolution
* 🌐 IPv6 (AAAA) resolution
* 🧭 Name Server (NS) discovery
* 📬 Mail Server (MX) lookup
* 📜 SPF record extraction
* ⚡ Zone transfer attempt
* 💣 Subdomain bruteforce (wordlist-based)
* 🎨 Clean and colorized CLI output

---

## 📸 Preview

```
===================DNS SWEEPER TOOL!=====================

IPV4=====
example.com -----> 93.184.216.34

IPV6=====
example.com -----> NOT FOUND
```

---

## 🛠️ Requirements

* Linux / WSL
* Bash
* `host` command

Install dependencies:

```bash id="6o2h1c"
sudo apt install dnsutils
```

---

## 📦 Installation

```bash id="p6r6qx"
git clone https://github.com/Douglas-fCruz/DNS_Sweeper
cd DNS_Sweeper
chmod +x dns_sweeper.sh
```

---

## ⚙️ Usage

### Basic scan

```bash id="3wbf8k"
./dns_sweeper.sh -d example.com
```

---

## 🧩 Options

| Flag               | Description          |
| ------------------ | -------------------- |
| `-h`, `--help`     | Show help menu       |
| `-d`, `--default`  | IPv4 + IPv6          |
| `-4`, `--ip4`      | IPv4 only            |
| `-6`, `--ip6`      | IPv6 only            |
| `-n`, `--ns`       | Name servers         |
| `-t`, `--transf`   | Zone transfer        |
| `-s`, `--sender`   | SPF records          |
| `-mx`, `--mail`    | Mail servers         |
| `-w`, `--wordlist` | Subdomain bruteforce |

---

## 💣 Subdomain Enumeration

```bash id="p9z9mq"
./dns_sweeper.sh -w subdomains.txt example.com
```

Automatically:

* Checks if subdomain exists
* Resolves multiple DNS records
* Displays structured output

---

## 📁 Project Structure

```
dns-sweeper/
├── dns_sweeper.sh
├── README.md
```

---

## ⚠️ Disclaimer

This tool is intended for **educational purposes and authorized testing only**.
The author is not responsible for misuse.

---

## 👨‍💻 Author

**Douglas Cruz**

---

## 🤝 Contributing

Pull requests are welcome.
For major changes, please open an issue first.

---

## ⭐ Support

If you like this project, consider giving it a **star ⭐** on GitHub!

---
