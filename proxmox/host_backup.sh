#!/bin/bash

# Настройки
PBS_REPO="XXX.XXX.X.XXX:storageName"    # Адрес PBS и название хранилища
PBS_NAMESPACE="namespace-name"              # Пространство имён PBS
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
        proxmox-backup-client backup "${BASENAME}.pxar:$DIR" --repository "$PBS_REPO" --ns "$PBS_NAMESPACE" --include-dev /etc/pve
    else
        echo "Резервное копирование $DIR в $BACKUP_PATH..."
        proxmox-backup-client backup "${BASENAME}.pxar:$DIR" --repository "$PBS_REPO" --ns "$PBS_NAMESPACE"
    fi
done

# Очистка переменной окружения (по желанию)
unset PBS_PASSWORD

echo "Резервное копирование завершено!"
