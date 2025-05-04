# Traefik

Пример конфигов обратного прокси Traefik

## ENV
При установке traefik руками env переменные можно указывать в отдельном файле. 

- Создадим env файлик:
```bash
nano /etc/traefik/.env
``` 

- Обновим systemd сервис traefik:
```bash
nano /etc/systemd/system/traefik.service
```
- Добавим строчку, которая указывает на env файлик:
```bash
EnvironmentFile=/your/path/to/env/file.env
```
- После изменений необходимо выполнить 2 команды:
```bash
sudo systemctl daemon-reload
sudo systemctl restart traefik
```
