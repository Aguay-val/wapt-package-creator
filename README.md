WAPT-Package-Creator
===

Script WAPT pour créer et uploader des paquets depuis linux sur un serveur WAPT.


- [English version](https://github.com/Aguay-val/wapt-package-creator/blob/master/README-en.md)
- [WAPT Késako  ?](#wapt-késako)
- [Why this repo ?](#why-this-repo)
- [How to use it ?](#how-to-use-it)


# WAPT Késako  ?

Wapt est un gestionnaire de paquet pour Windows qui se rapproche d'APT des distributions linux.

Plus d'informations disponibles  [ici](http://dev.tranquil.it/wiki/WAPT_-_apt-get_pour_Windows/en).

#  Pourquoi ce repo' ?

En tant qu'administrateur système, je suis habitué à travailler avec linux tous les jours. Mais je dois aussi travailler en tant qu'administrateur windows (Et ouais ¯\\_(ツ)_/¯).

WAPT offre la possibilité de créer un paquet à partir d'une CLI Windows. Mais je voulais le faire à partir de mon terminal debian. J'ai donc créé ce script qui m'a donné la possibilité de construire et d'uploader des paquets depuis linus sur le serveur wapt.

# Comment l'utiliser ?

Lancer le script depuis le dossier du paquet wapt. S'il n'est pas lancé depuis le dossier du paquet, alors il vous proposera de changer de répertoire !

Exemple avec `smp-7zip_16.4.0.0-1_all.wapt` du serveur https://wapt.lesfourmisduweb.org/tous-les-packages:

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

OU

Vous pouvez lancer :

 	wapt-build-upload.sh -h

OU

 	wapt-build-upload.sh -u <url> -l <login> -p -k <key>

| Paramètres | Infos     |
| :------------- | :------------- |
| -u url       | Seulement le FQDN <br> Exemple: -u wapt.server.info -> https://wapt.server.info/wapt       |
|-l login| Utilisateur utilisé pour s'authentifier auprès du serveur WAPT|
|-p| Permet de demander le mot de passe, **Ne pas le mettre en paramètre  !**|
|-k key| Clé utilisé pour signer le paquet. |

Si vous avez des questions n'hésitez pas à me contacter  ! :)

Ici : https://forum.tranquil.it/viewtopic.php?f=10&p=1581#p1581

Ou en créant une issue à ce repo' !
