## Part 1. Удаленное конфигурирование узла через Ansible

1.Создаем три ВМ `manager01` и `node01/02` с помощью vagrant  
- Пишем `Vagrantfile` без инструкций `provision` с прокидыванием портов с `node01` на `хост-машину`  
![Alt text](screenshots/image.png)

- Поднимаем машины при помощи `vagrant up`  
![Alt text](screenshots/image-1.png)

<a id="p1.1"></a>
2.Готовим `manager` как рабочую станцию для удаленного конфигурирования  
- Заходим на `manager01` по `ssh` и пробуем уже с него подключиться по `ssh` к `node01`  
![Alt text](screenshots/image-2.png)
Нет прав доступа

- Генерируем `ssh-ключ` без `passphrase`  
![Alt text](screenshots/image-16.png)

- Прокидываем ключ на обе ноды `node01/02` вручную путем копирования ключа  
![Alt text](screenshots/image-4.png)
![Alt text](screenshots/image-6.png)
![Alt text](screenshots/image-7.png)

- Снова пробуем подключиться с `manager01` к `node01`  
![Alt text](screenshots/image-8.png)
Успешно

- Копируем на `manager01` docker-compose.yml и nginx.conf с предыдущего проекта, а микросервис в прошлом проекте мы уже упаковали в контейнеры и запушили в docker hub, так что будем брать оттуда  
![Alt text](screenshots/image-9.png)

- Накатим `ansible` на `manager01` и создадим соответствующую папку, в которой создаем inventory-файл  
![Alt text](screenshots/image-10.png)
![Alt text](screenshots/image-11.png)

-  Прописываем в `inventory.ini` машины-серверы, к которым будем обращаться  
![Alt text](screenshots/image-12.png)

- Пингуем машины через `ansible`  
![Alt text](screenshots/image-13.png)

3.Пишем первый плейбук для Ansible, который выполняет: apt update, устанавливает docker, docker-compose, копирует compose-файл из manager'а и разворачивает микросервисное приложение  
![Alt text](screenshots/image-14.png)

- Дальше запускаем на `ansible` заданный `playbook.yml`  
![Alt text](screenshots/image-15.png)

4.Прогоняем тесты через `postman`  
![Alt text](screenshots/image-17.png)

5.Формируем роли  
- Создавать роли будем автоматически, поэтому сначала инициируем  
![Alt text](screenshots/image-18.png)

- Прописываем для каждой роли `tasks/main.yml`  

application: ![Alt text](screenshots/image-19.png)

apache: ![Alt text](screenshots/image-20.png)

postgres: ![Alt text](screenshots/image-25.png)

- Теперь прописываем отдельный `playbook_roles.yml` для запуска по ролям  
![Alt text](screenshots/image-23.png) 

- Далее запуск плейбука  
![Alt text](screenshots/image-24.png)

- Тесты `postman` для микросервиса на `node01`  
![Alt text](screenshots/image-26.png)

- Проверка доступности `apache` и `postgres` на `node02`  
![Alt text](screenshots/image-27.png)
![Alt text](screenshots/image-28.png)

## Part 2. Service Discovery

1.Пишем конфиги для `consul`  
- `consul_server.hcl`  
![Alt text](<screenshots/Снимок экрана 2025-07-16 в 18.05.15.png>)

- `consul_client.hcl`  
![Alt text](<screenshots/Снимок экрана 2025-07-16 в 18.05.29.png>)

2.Создаем четыре машины - `consul_server, api, manager и db` с прокидыванием соответствующих портов  
- `vagrantfile`  
![Alt text](<screenshots/Снимок экрана 2025-07-16 в 18.08.19.png>)
Далее так же, [как в предыдущем задании](#p1.1), прокидываем ключи с `manager` на остальные ВМ и накатываем `ansible` на `manager`

3.Пишем плейбуки и инициируем роли  
- Напишем плейбук для запуска ролей  
![Alt text](<screenshots/Снимок экрана 2025-07-16 в 19.45.32.png>)

- Собственно, инициация  
![Alt text](<screenshots/Снимок экрана 2025-07-16 в 19.44.10.png>) 

- Теперь описываем конкретные роли и что они включают   
3.1.`install_consul_server`  
- Плейбук  
![Alt text](<screenshots/Снимок экрана 2025-07-17 в 17.51.24.png>)  

- Проверяем, что машины отображаются в консуле во вкладке `nodes`  
![Alt text](<screenshots/Снимок экрана 2025-07-23 в 17.00.29.png>)

3.2.`install_consul_client`  
- Плейбук
![Alt text](<screenshots/Снимок экрана 2025-07-21 в 16.48.56.png>)
![Alt text](<screenshots/Снимок экрана 2025-07-21 в 16.49.05.png>)

- Далее регистрируем нашу БД и сам сервис в консуле, как `sidecar proxy`, для того, чтобы не обращаться к БД напрямую
![Alt text](<screenshots/Снимок экрана 2025-07-23 в 16.57.34.png>)
![Alt text](<screenshots/Снимок экрана 2025-07-23 в 16.57.42.png>)  

- Накатываем `envoy` по отдельности на `api` и `db`, создавая его как два разных `systemd unit`  
![Alt text](<screenshots/Снимок экрана 2025-07-23 в 17.03.30.png>)
![Alt text](<screenshots/Снимок экрана 2025-07-23 в 17.03.34.png>)

- Проверяем, что наши сервисы отобразились в консуле во вкладке `services`  
![Alt text](<screenshots/Снимок экрана 2025-07-23 в 16.58.44.png>)

3.3.`install_db`  
- Плейбук  
![Alt text](<screenshots/Снимок экрана 2025-07-21 в 16.49.21.png>)

3.4.`install_hotels_service`  
- Плейбук    
![Alt text](<screenshots/Снимок экрана 2025-07-21 в 16.49.36.png>)  
- Накатываем сервис, как `systemd unit`, прокидывая заданные переменные окружения  
![Alt text](<Снимок экрана 2025-07-23 в 17.06.17.png>)

4.Проверяем работоспособность CRUD-операций над сервисом отелей, делая запросы  
- Создаем отель  
![Alt text](<screenshots/Снимок экрана 2025-07-23 в 14.31.28.png>)  
и проверяем что добавился отель  
![Alt text](<screenshots/Снимок экрана 2025-07-23 в 14.31.56.png>)

- Смотрим все отели  
![Alt text](<screenshots/Снимок экрана 2025-07-23 в 14.33.16.png>)  