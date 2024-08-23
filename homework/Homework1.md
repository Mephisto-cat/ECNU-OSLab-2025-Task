# Homework1

## 一、Install VirtualBox + Debian

### (1) partition table

分区表是一种数据结构，被操作系统用来管理如何将硬盘驱动器或固态硬盘，划分为多个逻辑单元，这些逻辑单元被称为分区。每个分区都可以被格式化并用作独立的存储区域。

**分区表主要分为两种：**

**1、MBR（主引导记录）分区表**

**2、GPT（GUID 分区表）**

MBR是一种较旧的标准，目前一般采用GPT标准分区，GPT标准的好处如下：

- GPT 用于支持更大的磁盘和更多的分区数量。
- GPT 允许每个磁盘有最多 128 个分区，并且没有 MBR 那样的大小限制，理论上可以支持超过 8 ZiB 的磁盘。
- GPT 使用全局唯一标识符 (GUID) 来唯一标识每个分区，并且具有内置的备份分区表来提高容错能力。



### (2) boot loader

Boot loader的主要任务是在操作系统内核加载到内存之前控制系统的启动流程，负责初始化硬件设备、设置内存管理、检测和初始化磁盘驱动器以及加载操作系统内核到内存中执行。

Linux常见的bootloader **GRUB**：通过将硬件控制权移交给Linux内核启动操作系统

- GRUB 是一个广泛使用的多系统引导程序，支持多种操作系统和文件系统。
- GRUB 2 是大多数现代 Linux 发行版的默认引导加载程序，并且具有丰富的功能，如图形界面、网络支持等。



### (3) SSH

SSH（Secure Shell）是一种用于远程登录和管理网络设备的安全协议，它为网络服务提供了安全的加密通道。SSH 协议不仅限于远程登录，还可以用于文件传输（SFTP）、端口转发等多种用途。

**SSH的基本组成方式**

1. SSH 客户端:

   SSH 客户端用于发起 SSH 连接，例如在 Linux、macOS 或 Windows 上的命令行工具 `ssh`。

2. SSH 服务器:

   SSH 服务器接收来自客户端的连接请求，例如在 Linux 服务器上运行的 `sshd` 服务。

**SSH的基本使用方法**

1、远程登入：其中user是目标主机上的用户名，hostname是目标主机的域名或IP地址。

```sh
ssh [options] user@hostname
```

我们也可以使用 -p 参数指定端口号，例如

```sh
ssh -p 2222 user@hostname
```

2、密钥认证

- 生成密钥对

  ```sh
  ssh-keygen -t rsa
  ```

- 复制公钥到远程服务器

  ```sh
  ssh-copy-id user@hostname
  ```

- 使用密钥认证登入

  ```sh
  ssh -i ~/.ssh/id_rsa user@hostname
  ```


**实例**：连接到老师办公室的主机

![](https://img2024.cnblogs.com/blog/3492979/202408/3492979-20240823091706671-893514268.png)



### (4) [headless]

headless通常是指一种没有GUI的操作模式。

**1. Headless 浏览器**

Headless 浏览器是一种没有图形界面的浏览器，可以在没有显示输出的情况下运行。这在自动化测试、网页抓取和性能测试等领域非常有用。

**2. Headless 操作系统**

在操作系统层面，headless 模式意味着系统不依赖任何显示硬件，如显示器、键盘或鼠标。这种模式适用于服务器环境，因为服务器通常不需要直接与用户交互。



### (5) vscode + ssh

vscode支持通过ssh连接到远程服务器并进行开发，操作主要分为两步：

**1、在vscode中安装Remote-SSH插件**

![插件](https://i-blog.csdnimg.cn/blog_migrate/a97bc90750e4e03c3fa910182e5bcdf0.png#pic_center)

**2、配置ssh文件**

```sh
Host myserver
    HostName example.com
    User username
    Port 22
    IdentityFile ~/.ssh/id_rsa
```

其中 myserver是连接别名，HostName 是远程服务器的地址，User 是登录用户名，Port 是 SSH 端口，IdentityFile 是你的私钥文件路径。

通过ssh，即使安装了开发环境的电脑不在手边，我们也可以远程连接到那台电脑的vscode，并使用它进行代码的编写。（平板电脑也可以通过这种方式连接到宿舍的电脑，从而减少出行的负担）。

### (6) windows terminal + ssh

要在windows terminal中使用ssh，首先需要安装OpenSSH的服务端以及客户端。

打开windows terminal，使用以下命令连接到远程服务器：

```sh
ssh username@hostname
```

如果有密码将被提示输入密码。



## 二、Install WSL2 + Debian

首先打开cmd或者powershell，输入以下命令安装wsl命令

```powershell
wsl --install
```

接着安装Debian

```powershell
wsl --install -d Debian
```

运行debian（大小写不敏感）

```powershell
debian
```



## 三、Questions

### What's von Neumann architecture?

冯·诺伊曼架构主要包括：

1. **存储程序概念**：计算机能够存储指令集，并且这些指令集可以被计算机自身读取和执行。这意味着程序和数据都以相同的格式存储在内存中，计算机能够根据需要加载并执行不同的程序。
2. **中央处理器（CPU）**：负责执行指令，进行算术逻辑运算，并控制计算机的其他部分。
3. **内存**：用来存储程序指令和数据。在冯·诺依曼架构中，内存是统一寻址的，这意味着程序和数据都存储在同一块存储空间内。
4. **输入输出设备**：用于与外部世界交互，例如键盘、鼠标、显示器等。
5. **总线系统**：提供数据传输的通道，使得CPU、内存以及输入输出设备之间可以相互通信。



### how to get hardware information?

#### 在window下

找到设备管理器直接查看，或是打开cmd，输入

```sh
systeminfo
```

这个命令将显示关于系统的详细信息，包括操作系统版本、BIOS 版本、处理器信息、内存信息等。

#### 在linux下

linux可以通过安装一些强大的命令，使用这些命令可以列出详细的硬件信息，比如lshw，dmidecode。

如果不想安装命令，我们也可以通过linux自带的命令(cat)来查看硬件信息，比如：

查看cpu信息：

```sh
cat /proc/cpuinfo
```

查看内存信息：

```sh
cat /proc/meminfo
```

查看磁盘信息：

```sh
cat /sys/class/disk/*/device/model
```



### how to change the computer/host name?

windows下（windows11）点开任务栏设置，再点击系统，再正上方便可以看到为电脑重命名的选项。重启后生效。

linux下（Debian），我们可以使用以下命令更改hostname：

```sh
sudo vim /etc/hostname
```

打开hostanme文件更改用户名，保存并退出。重启后生效。



### what is gpt?

GPT（GUID 分区表）是一种用于布局磁盘驱动器分区结构的标准。它的全称是“GUID 分区表”，是替代旧式 MBR（主引导记录）分区方案的一种新技术。

#### GPT 的主要特点包括：

1. **支持更大的磁盘**：GPT 支持超过 2 TB 的磁盘容量，而 MBR 最大只能支持 2 TB 的磁盘。
2. **更多的分区**：GPT 支持更多的分区数量，最多可以创建 128 个主分区，而 MBR 通常限制为 4 个主分区。
3. **更好的安全性**：GPT 使用 GUID（全局唯一标识符）来唯一标识每个分区，这有助于防止分区冲突。此外，GPT 还具有备份分区表的功能，可以在主分区表损坏时恢复数据。
4. **元数据的保护**：GPT 在磁盘的开头和结尾分别维护一份分区表副本，提高了数据的可靠性和可恢复性。
5. **兼容性**：虽然 GPT 提供了许多改进，但它可能不完全兼容某些旧的操作系统和硬件平台。不过，随着技术的发展，越来越多的现代系统开始支持 GPT。

#### GPT 的应用场景：

- **大型服务器**：由于支持更大的磁盘容量，GPT 经常用于服务器和高性能计算环境中。
- **UEFI 引导**：GPT 通常与 UEFI（统一可扩展固件接口）一起使用，这是现代 PC 中取代传统 BIOS 的标准。
- **个人电脑**：许多现代的个人电脑和笔记本电脑也使用 GPT 格式的磁盘进行分区。



### what is ext4 / btrfs?

EXT4 和 Btrfs 都是 Linux 文件系统，它们各自具有不同的特性和用途。

#### EXT4

EXT4（第四扩展文件系统）是 Linux 中广泛使用的文件系统之一，它是 EXT3 的后续版本，并且向后兼容 EXT3。EXT4 的主要特点包括：

1. **高性能**：EXT4 优化了文件系统性能，特别是在大文件和小文件的处理上。
2. **更大的文件系统**：EXT4 支持的最大文件系统大小为 1 EB（1 exabyte），单个文件最大可达 16 TB。
3. **更快的写入速度**：通过延迟分配（delayed allocation）和预分配（preallocation）技术，EXT4 可以更高效地管理磁盘空间。
4. **在线扩展**：EXT4 支持在线扩展，允许用户在不卸载文件系统的情况下增加文件系统的大小。
5. **日志记录**：EXT4 支持日志记录，可以在文件系统损坏时快速恢复数据。
6. **子卷**：EXT4 支持子卷，允许在一个文件系统中创建独立的命名空间。
7. **文件系统检查工具**：EXT4 提供了 fsck 工具，用于修复文件系统的损坏。

#### Btrfs

Btrfs是一种更为先进的文件系统，旨在解决大规模存储的需求。Btrfs 的主要特点包括：

1. **自动碎片整理**：Btrfs 自动进行后台碎片整理，避免了文件系统的性能下降。
2. **子卷和快照**：Btrfs 支持子卷和快照，可以轻松地创建文件系统的快照或子卷，便于备份和恢复。
3. **RAID 支持**：Btrfs 内置了对 RAID 0、1、10 的支持，可以实现数据冗余和性能提升。
4. **灵活的存储池**：Btrfs 允许将多个物理磁盘合并成一个逻辑存储池，从而简化了存储管理。
5. **透明压缩**：Btrfs 支持透明的数据压缩，可以减少磁盘占用空间。
6. **校验和和自我修复**：Btrfs 使用校验和来检测数据损坏，并且能够在可能的情况下自动修复损坏的数据。
7. **复制和去重**：Btrfs 支持文件和目录级别的复制和去重功能，有助于节省磁盘空间。

#### 优劣

- **稳定性**：EXT4 被认为更加稳定成熟，适用于大多数场景。
- **特性**：Btrfs 提供了许多高级特性，适合那些需要这些特性的高级用户或企业环境。
- **兼容性**：大多数 Linux 发行版默认支持 EXT4，并且它在各种硬件和软件环境中都有很好的兼容性。



### how to know / change partitions?

在linux中，我们可以使用一些工具来查看/更改分区，以fdisk为例。

列出所有磁盘及其分区信息

```sh
sudo fdisk -l
```

选择要更改的磁盘，其中/dev/sda是你要更改的磁盘。

```sh
sudo fdisk /dev/sda
```

更改分区

- 输入 `p` 查看当前分区表。
- 输入 `d` 删除分区。
- 输入 `n` 创建新分区。
- 输入 `t` 更改分区类型。
- 输入 `w` 保存更改并退出。



### how to boot a linux machine?

1. **POST (Power-On Self Test)**: 当机器通电后，BIOS（或 UEFI）首先执行 POST 测试来检查硬件是否正常工作。
2. **BIOS/UEFI**: BIOS 或 UEFI 接着查找并加载引导加载程序。这个引导加载程序通常是 GRUB（GRand Unified Bootloader）。
3. **GRUB (或类似的引导加载程序)**: GRUB 加载后会显示一个菜单，让用户选择要启动的操作系统或内核版本。
4. **加载内核**: 用户选择内核版本后，GRUB 将加载选定的 Linux 内核。
5. **初始化**: 内核加载后，开始初始化过程，这通常涉及到启动 init 进程或 systemd 服务管理器。
6. **启动服务**: 初始化进程启动必要的服务和守护进程。
7. **登录**: 系统准备就绪后，用户可以登录并开始使用系统。



### Is Harmony an OS?

我认为鸿蒙系统是一个操作系统。操作系统的定义是管理和协调计算机硬件资源以及软件资源，为用户提供了一个友好的交互界面，并为应用程序提供了一个运行环境的一个最基础的软件。

显然鸿蒙系统做到了这一点。例如在华为手机上，鸿蒙确实为用户提供了一个交互界面，也能为市面上大部分的应用程序提供一个运行环境。



## 四、Linux Basics

### file operations

下面介绍一些常用的文件操作命令：

**cd**：切换目录

```sh
cd /
cd /etc
```

**touch**：创建一个新文件（可以创建各种后缀不同的文件）

```sh
touch filename.txt
touch ac.cpp
touch hello.py
```

**mkdir**：创建一个文件夹（注意是在当前目录下创建）

```sh
mkdir acm
```

**cat**：查看文件内容

```sh
cat filename.txt
```

**less**：分页查看文件内容

```sh
less filename.txt
```

**ls**：列出**当前**目录内容（-a可查看隐藏文件）

```sh
ls
```

**mv**：移动文件或重命名文件

```sh
mv oldname.txt newname.txt
mv oldname.txt /path/to/new/location
```

**cp**：复制文件

```sh
cp oldfile.txt copyfile.txt
```

**rm**：删除文件

```sh
rm file.txt
```

**rmdir**：删除空目录（注意是空目录，如果要删除非空目录，要加上 -r 参数）

```sh
rmdir directoryname
```

**diff**：比较两个文件的差异（在算法题的对拍文件中常用，可以用以比较std和solve输出结果的差异）

```sh
diff file1.txt file2.txt
```

### hwlist

hwlist是一个获取系统硬件详细信息的工具。



## 五、BtrFS

### create filesystem

#### raid

### create subvolume

#### snapshot



## 六、[LVM]

## 七、[OpenZFS]

## 八、[ReFS]

