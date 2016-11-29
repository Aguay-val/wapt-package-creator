WAPT-Package-Creator
===
Bash script to create wapt package and upload it to a wapt server.

- [What is WAPT ?](#what-is-wapt)
- [Why this repo ?](#why-this-repo)
- [How to use it ?](#how-to-use-it)

# What is WAPT ?

WAPT is a package manager for Windows inspired by "apt" from debian based linux.

You can get more information of it [here](http://dev.tranquil.it/wiki/WAPT_-_apt-get_pour_Windows/en).

# Why this repo ?

As a system administrator, i'm used to work with linux everyday. But i also have to work as a windows administrator (God damn it !).

WAPT offer the possibility to create package from Windows CLI. But i wanted to do it from my debian terminal. So i created this script which gave me the possibility to build and upload packages from debian to the wapt server.

# How to use it ?

Launch this script into the directory of wapt package.

Exemple with `smp-7zip_16.4.0.0-1_all.wapt` from https://wapt.lesfourmisduweb.org/tous-les-packages:

    Aguays-MBA 福 ~/Downloads/smp-7zip_16.4.0.0-1_all
    10307 ◯ : tree ./
    ./
    ├── 7z1604-x64.msi
    ├── 7z1604.msi
    ├── WAPT
    │   ├── control
    │   ├── icon.png
    │   ├── manifest.sha1
    │   ├── signature
    │   └── wapt.psproj
    └── setup.py
    Aguays-MBA 福 ~/Downloads/smp-7zip_16.4.0.0-1_all
    10308 ◯ : wapt-build-upload.sh -u localhost -l admin -p -k ~/my.wapt.pem

OR

You can try to do :

 	wapt-build-upload.sh -h

OR

 	wapt-build-upload.sh -u <url> -l <login> -p -k <key>

| Parameter | Infos     |
| :------------- | :------------- |
| -u url       | Only fqdn <br> Exemple: -u wapt.server.info -> https://wapt.server.info/wapt       |
|-l login| Login used to connect to wapt server.|
|-p| Ask for password, do not write your password as parameter !|
|-k key| Key used to sign packages |

If you have any question do not hesitate to contact me ! :)

Here : https://forum.tranquil.it/viewtopic.php?f=10&p=1581#p1581

Or with an issue of this repo.
