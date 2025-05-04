# Полезные команды для работы с Proxmox

### 1. Прокидываем хостовую директорию в lxc контейнер:
```
pct set lxcid -mp0 /path/to,mp=/path/to
```

lxcid - это id lxc контейнера

mp0 - точка монтирования, может быть от 0 до 7

/path/to - хостовой путь до директории которую нужно закинуть в контейнер

mp=/path/to - путь в самом lxc контейнере, куда закинется хостовая директория

Таким образом готовая команда будет иметь вид:
```
pct set 100 -mp0 /home/External,mp=/home/External
```

P.S: Для взаимодействия с файлами (r/w) в прокинутой директории из контейнера необходимо чтобы контейнер был привелигерованный.

### 2. Прокидываение физического накопителя целиком (например съемный жесткий диск) в VM: 
```
qm set lxcid -sataN /dev/disk/by-id/usbid
```

lxcid - id виртуальной машины

sataN - sata контроллер с указанием его номера

/dev/disk/by-id/ - этот путь является обязательным и путь ведет прямиком к устройству

usbid - тут должен быть usbid устройства, которое хочешь прокинуть. Чтобы узнать его можно воспользоваться командой после чего вставить вместо usbid

Полный и правильный вид команды будет иметь вид:
```
qm set 111 -sata1 /dev/disk/by-id/usb-_USB_FLASH_DRIVE_XXXXXXXXXXXXXXX-0:0-part1
```

### 3. Telegram Webhook URL для уведомлений в телеграмм группу:
```
https://api.telegram.org/bot{{ secrets.BOT_TOKEN }}/sendMessage?chat_id={{ secrets.CHAT_ID }}&message_thread_id={{ secrets.THREAD_ID }}&text={{ url-encode "Proxmox Notification" }}%0A%0ATitle:+{{ url-encode title }}%0AMessage:+{{ url-encode message }}%0ASeverity:+{{ url-encode severity }}%0ATime:+{{ timestamp }}
```

BOT_TOKEN - токен телеграмм бота

CHAT_ID - айди чатика

THREAD_ID - айди топика в чатике 

Данные переменные необходимо добавить в Secrets раздел и присвоить им соответствующие значения.
Сам URL необходимо вставить в поле Method/URL (Метод POST)

<img width="695" alt="image" src="https://github.com/user-attachments/assets/7371d035-cb48-4e75-b689-72213534925e" />

### 4. Скрипт резервного копирования директорий с хоста Proxmox в Proxmox Backup Server

Краткое описание переменных скрипта host_backup.sh

```
#!/bin/bash

# Настройки
PBS_REPO="XXX.XXX.X.XXX:storageName"    # Адрес PBS и название хранилища
PBS_PASSWORD="password"         # Пароль для доступа к PBS
BACKUP_DIRS=("/path/to/dir1" "/path/to/dir2")    # Директории для резервного копирования
BACKUP_NAME="system-backup-name"               # Имя бэкапа

# Установка переменной окружения для пароля
export PBS_PASSWORD

# Выполнение резервного копирования каждой директории
for DIR in "${BACKUP_DIRS[@]}"; do
    BASENAME=$(basename "$DIR")
    BACKUP_PATH="${BACKUP_NAME}-${BASENAME}.pxar"

    if [[ "$DIR" == "/etc" ]]; then
        echo "Резервное копирование /etc с параметром --include-dev..."
        proxmox-backup-client backup "${BASENAME}.pxar:$DIR" --repository "$PBS_REPO" --include-dev /etc/pve
    else
        echo "Резервное копирование $DIR в $BACKUP_PATH..."
        proxmox-backup-client backup "${BASENAME}.pxar:$DIR" --repository "$PBS_REPO"
    fi
done

# Очистка переменной окружения (по желанию)
unset PBS_PASSWORD

echo "Резервное копирование завершено!"
```
XXX.XXX.X.XXX:storageName - Указать IP адрес сервера PBS:имя хранилища в PBS

password - пароль от PBS

Необходимо указать через пробел директории, которые необходимо бэкапить:
```
BACKUP_DIRS=("/path/to/dir1" "/path/to/dir2")
```

При желании можно добавить этот скрипт выполнятсья по крону.

```
crontab -e
```
в конце файла добавить строчку
```
30 21 * * * /root/host_backup.sh >> /var/log/host_backup.log 2>&1
```
30 - минуты

21 - часы

То есть, скрипт будет выполняться каждый день в 21:30. А строчка /var/log/host_backup.log 2>&1 будет выводить лог в файл host_backup.log

Проверить список всех задач по крону можно командой:

```
сcrontab -l
```


