<h1 align="center">Настройка VPS сервера и установка необходимого софта</h2>

## 1. Настройка сервера
### Обновление 
```bash
apt-get update && apt get upgrade
```
### Установка нужного ПО
Может и не очень нужного, однако я его ставлю в большинстве случаев
```bash
sudo apt install -y fail2ban mc net-tools cron socat curl wget
```
### Включение bbr 
Это поможет увеличить пропускную способность сетевого интерфейса
```bash
sudo echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p
```
### Настройка fail2ban
Утилита для автоматического бана хостов, которые превысили количество попыток входа по SSH (количество устанавливается параметром maxretry)
- Откроем файл для редактирования
```bash
sudo nano /etc/fail2ban/jail.conf
```
- Внесем изменения
```bash
[sshd]
#mode   = normal
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
enabled = true
maxretry = 4
bantime = 1d
logencoding = UTF-8
filter = sshd
```
- Сохраняем файл CTRL+C ENTER CTRL+X
- Включим автозагрузку, запустим и проверим работу
```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo fail2ban-client status sshd
```
![fail2ban](https://github.com/user-attachments/assets/57899ed3-4f7c-4256-9fb2-4eeec5a1b10d)

### Меняем стандартный порт SSH 
```bash
nano /etc/ssh/sshd_config
```
необходимо раскоментировать строку и поменять порт на любой другой, например, на 1121:
```bash
#Port 22
```
После перезагружаем демон и рестартим ssh сервис:
```bash
systemctl daemon-reload
system restart ssh
```
## Установка 3X-UI
### Установка 

https://github.com/MHSanaei/3x-ui

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```
### Настройка

## Установка WireGuard с веб-интерфейсом wg-easy
- Создаем директорию в удобном виде
```bash
sudo mkdir /opt/wg-easy
```
- Создаем внутри файл docker-compose.yml
```bash
sudo nano /opt/wg-easy/docker-compose.yml
```
- Вставляем следующий код:
```yml
volumes:
  etc_wireguard:

services:
  wg-easy:
    environment:
      # Change Language:
      # (Supports: en, ua, ru, tr, no, pl, fr, de, ca, es, ko, vi, nl, is, pt, chs, cht, it, th, hi, ja, si)
      - LANG=ru
      # ⚠️ Required:
      # Change this to your host's public address
      - WG_HOST=raspberrypi.local # ваш айпи или ваше доменное имя

      # Optional:
      - PASSWORD_HASH=$$2y$$10$$hBCoykrB95WSzuV4fafBzOHWKu9sbyVa34GJr8VV5R/pIelfEMYyG # Хэш вашего пароля, генерацию рассмотрим чуть позже
      # - PORT=51821
      # - WG_PORT=51820
      # - WG_CONFIG_PORT=92820
      # - WG_DEFAULT_ADDRESS=10.8.0.x
      # - WG_DEFAULT_DNS=1.1.1.1
      # - WG_MTU=1420
      # - WG_ALLOWED_IPS=192.168.15.0/24, 10.0.1.0/24
      # - WG_PERSISTENT_KEEPALIVE=25
      # - WG_PRE_UP=echo "Pre Up" > /etc/wireguard/pre-up.txt
      # - WG_POST_UP=echo "Post Up" > /etc/wireguard/post-up.txt
      # - WG_PRE_DOWN=echo "Pre Down" > /etc/wireguard/pre-down.txt
      # - WG_POST_DOWN=echo "Post Down" > /etc/wireguard/post-down.txt
      # - UI_TRAFFIC_STATS=true
      # - UI_CHART_TYPE=0 # (0 Charts disabled, 1 # Line chart, 2 # Area chart, 3 # Bar chart)
      # - WG_ENABLE_ONE_TIME_LINKS=true
      # - UI_ENABLE_SORT_CLIENTS=true
      # - WG_ENABLE_EXPIRES_TIME=true
      # - ENABLE_PROMETHEUS_METRICS=false
      # - PROMETHEUS_METRICS_PASSWORD=$$2a$$12$$vkvKpeEAHD78gasyawIod.1leBMKg8sBwKW.pQyNsq78bXV3INf2G # (needs double $$, hash of 'prometheus_password'; see "How_to_generate_an_bcrypt_hash.md" for generate the hash)

 image: ghcr.io/wg-easy/wg-easy
    container_name: wg-easy
    volumes:
      - etc_wireguard:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
      # - NET_RAW # ⚠️ Uncomment if using Podman
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
```
Обратите внимание на параметры WG_HOST и PASSWORD_HASH. WG_HOST мы меняем на свой IP адрес или доменное имя, а PASSWORD_HASH мы сгенерируем чуть позже. Он почему-то не генерируется, если контейнер не запущен.
- Сохраняем файл CTRL+C ENTER CTRL+X
- Запускаем наш контейнер
```bash
docker compose up --detach
```
- Теперь пришло время генерации хэша. Для этого используем команду (заменив YOUR_PASSWORD на ваш пароль):
```bash
docker run --rm -it ghcr.io/wg-easy/wg-easy wgpw 'YOUR_PASSWORD'
```
- В результате вы получите нечто вот такое:
```bash
PASSWORD_HASH='$2b$12$coPqCsPtcFO.Ab99xylBNOW4.Iu7OOA2/ZIboHN6/oyxca3MWo7fW'
```
- Копируем все что в кавычках и открываем снова на редактирование docker-compose.yml
```bash
sudo nano /opt/wg-easy/docker-compose.yml
```
- Обязательно после знака = у нас должен остаться один $ (то есть суммарно 2) и после него копируем наш хэш:
```bash
- PASSWORD_HASH=$$2y$$10$$hBCoykrB95WSzuV4fafBzOHWKu9sbyVa34GJr8VV5R/pIelfEMYyG
```
- Сохраняем файл CTRL+C ENTER CTRL+X
- И теперь снова запускаем контейнер
```bash
docker compose up --detach
```
- Проверяем корректность запуска (здесь же вы увидите запущенный Marzban)
```bash
docker ps -a
```
![docker](https://github.com/user-attachments/assets/fba9fda3-1876-47d9-8aa7-c414fcfcf20e)
Теперь у нас доступен веб-интерфейс WireGuard по адресу http://ваш_айпи_или_домен:51821
Заходим, добавляем клиента, скачиваем конфиг и радуемся жизни.
Однако если вы хотите более подробно настроить WireGuard, например указать другие ALLOWED_IPS и тп, то ниже я приведу список возможно нужных параметров:
| Env | Default | Example | Description                                                                                                                                          |
| - | - | - |------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PORT` | `51821` | `6789` |  TCP порт для Web UI.                                                                                                                                 |
| `WEBUI_HOST` | `0.0.0.0` | `localhost` | IP адрес, к которму привязывается WEBUI.                                                                                                                          |
| `PASSWORD_HASH` | - | `$2y$05$Ci...` | Если включено - запрашивает ввод пароля при авторизации |
| `WG_HOST` | - | `vpn.myserver.com` | Публичное имя вашего сервера.                                                                                                              |
| `WG_DEVICE` | `eth0` | `ens6f0` | Ethernet интерфейс, в который должен быть перенаправлен трафик.                                                                                   |
| `WG_PORT` | `51820` | `12345` | Публичный UDP-порт вашего VPN-сервера. WireGuard будет слушать его внутри контейнера Docker.                                 |
| `WG_MTU` | `null` | `1420` | MTU, который будут использовать клиенты.                                                                                            |
| `WG_PERSISTENT_KEEPALIVE` | `0` | `25` | Значение в секундах, чтобы держать «подключение» открытым. Если это значение 0, то соединения не будут сохранены..                                            |
| `WG_DEFAULT_ADDRESS` | `10.8.0.x` | `10.6.0.x` | Диапазон IP-адресов клиентов. |
| `WG_DEFAULT_DNS` | `1.1.1.1` | `8.8.8.8, 8.8.4.4` | DNS Сервера, которые будут использовать клиенты. |
| `WG_ALLOWED_IPS` | `0.0.0.0/0, ::/0` | `192.168.15.0/24, 10.0.1.0/24` | Разрешенные IP адреса клиентов. |
| `WG_ENABLE_EXPIRES_TIME` | `false` | `true`                         | Включение срок действия клиентов |
| `LANG` | `en` | `de` | Язык Web UI (Поддержка: en, ua, ru, tr, no, pl, fr, de, ca, es, ko, vi, nl, is, pt, chs, kht, it, th, hi, ja, si).                                        |
| `UI_TRAFFIC_STATS` | `false` | `true` | Включить подробную статистику клиентов RX/TX в Web UI |
| `WG_ENABLE_ONE_TIME_LINKS` | `false` | `true` | Включить отображение и генерацию коротких одноразовых ссылок для загрузки (срок действия 5 минут) |
| `MAX_AGE` | `0` | `1440` | Максимальный возраст сеансов веб-интерфейсов в минутах. 0Это означает, что сеанс будет существовать до тех пор, пока браузер не будет закрыт. |
| `UI_ENABLE_SORT_CLIENTS` | `false` | `true`                         | Включить сортировку по клиентов по имени   |
| `ENABLE_PROMETHEUS_METRICS` | `false` | `true`                       | Включить метрики для Prometheus `http://0.0.0.0:51821/metrics` и `http://0.0.0.0:51821/metrics/json`|
| `PROMETHEUS_METRICS_PASSWORD` | - | `$2y$05$Ci...` | Включает авторизацию для отправки метрик |

## 

## 

## 

## 

## 

## 

## Полезное

### Проверка IP сервера на блокировки зарубежными сервисами: 
```bash
bash <(curl -Ls IP.Check.Place) -l en
```
### Параметры сервера и проверка скорости к российским провайдерам:
```bash
wget -qO- speedtest.artydev.ru | bash
```
### Параметры сервера и проверка скорости к зарубежным провайдерам:
```bash
wget -qO- bench.sh | bash
```
