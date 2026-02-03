# 🐚 Mini Command-Line Shell (ARM Assembly)

> A lightweight, interactive command-line interface (CLI) built entirely from scratch using **ARM32 Assembly** on Linux.

![Assembly](https://img.shields.io/badge/Language-ARM32%20Assembly-blue.svg) ![Platform](https://img.shields.io/badge/Platform-Linux-orange.svg) ![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📖 Overview
This project demonstrates low-level systems programming by implementing a functional shell without relying on standard C libraries (libc). It interacts directly with the Linux kernel using **system calls** (EABI) to handle input/output, string parsing, and memory management.

It was developed as part of the **CO1020: Computer Systems Programming** course at the University of Peradeniya (Group 63).

---

## 🎥 Project Demo
**See the shell in action!**

[▶️ **Click here to watch the Demo Video**](https://drive.google.com/file/d/1VHru6qrrMt-_br-3AReetOe_Bg4dlOTd/view?usp=drivesdk)

---

## ✨ Features
The shell provides an interactive prompt `shell>` and supports the following commands:

### 🛠 Built-in Commands
| Command | Description |
| :--- | :--- |
| `hello` | Prints "Hello World!" to the standard output. |
| `help` | Displays the list of available commands. |
| `clear` | Clears the terminal screen using ANSI escape codes. |
| `exit` | Terminates the shell session gracefully. |

### 🧮 Custom Arithmetic Commands
| Command | Usage | Description |
| :--- | :--- | :--- |
| `hex` | `hex <number>` | Converts a decimal number to Hexadecimal (e.g., `hex 255` -> `0xFF`). |
| `add` | `add <num1> <num2>` | Adds two decimal integers and displays the result. |

---

## 🚀 How to Build & Run
You can run this on a native ARM Linux environment (like a Raspberry Pi) or using QEMU on x86 machines.

### 1. Prerequisites
* GNU Assembler (`as`)
* GNU Linker (`ld`)
* *(Optional)* `qemu-arm` if running on a non-ARM PC.

### 2. Assembly & Linking
Run the following commands in your terminal to compile the source code:

```bash
# Assemble the source file
as -o shell.o shell.s

# Link object file to create executable
ld -o shell shell.o
