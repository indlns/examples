# Настройка VPS сервера и установка необходимого

## 1. Обновление

```
apt-get update && apt get upgrade
```


## 2. Меняем стандартный порт SSH 
```
nano /etc/ssh/sshd_config
```
необходимо раскоментировать строку и поменять порт на любой другой, например, на 1121:
```
#Port 22
```
После перезагружаем демон и рестартим ssh сервис:
```
systemctl daemon-reload
system restart ssh
```
## 3. Установка панельки 3X-UI
Устанавливаем панельку https://github.com/MHSanaei/3x-ui

```
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

## 4. 

## 5.

## 6.

## 7.

## 8.

## 9.

## 10.
