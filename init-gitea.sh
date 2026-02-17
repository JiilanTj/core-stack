#!/bin/bash

# Generate Gitea app.ini dengan SSH port 2222
cd /opt/core-stack

# Buat config directory
docker run --rm -v core-stack_gitea_data:/data alpine mkdir -p /data/gitea/conf

# Buat app.ini dengan SSH port 2222
docker run --rm -v core-stack_gitea_data:/data alpine sh -c 'cat > /data/gitea/conf/app.ini << "EOF"
APP_NAME = Gitea
RUN_MODE = prod
WORK_PATH = /data/gitea

[repository]
ROOT = /data/git/repositories

[repository.local]
LOCAL_COPY_PATH = /data/gitea/tmp/local-repo

[repository.upload]
TEMP_PATH = /data/gitea/uploads

[server]
PROTOCOL = http
DOMAIN = gitea.sapacode.id
HTTP_PORT = 3000
ROOT_URL = http://gitea.sapacode.id:3636/
STATIC_URL_PREFIX = 
DISABLE_SSH = false
SSH_PORT = 2222
LFS_START_SERVER = true
LFS_CONTENT_PATH = /data/git/lfs
OFFLINE_MODE = false

[database]
DB_TYPE = postgres
HOST = core-postgres:5432
NAME = gitea_db
USER = gitea_user
PASSWD = WaduhAngkongNangLai11221212
SSL_MODE = disable

[session]
PROVIDER_CONFIG = /data/gitea/sessions
PROVIDER = file

[picture]
AVATAR_UPLOAD_PATH = /data/gitea/avatars
REPOSITORY_AVATAR_UPLOAD_PATH = /data/gitea/repo-avatars

[attachment]
PATH = /data/gitea/attachments

[log]
MODE = console
LEVEL = info
ROOT_PATH = /data/gitea/log

[security]
INSTALL_LOCK = true
SECRET_KEY = 

[service]
DISABLE_REGISTRATION = false
REQUIRE_SIGNIN_VIEW = false
REGISTER_EMAIL_CONFIRM = false
ENABLE_NOTIFY_MAIL = false
ALLOW_ONLY_EXTERNAL_REGISTRATION = false
ENABLE_CAPTCHA = false
DEFAULT_KEEP_EMAIL_PRIVATE = false
DEFAULT_ALLOW_CREATE_ORGANIZATION = true
DEFAULT_ENABLE_TIMETRACKING = true
NO_REPLY_ADDRESS = noreply.localhost

[lfs]
PATH = /data/git/lfs
EOF'

echo "Config created! Restarting Gitea..."
docker compose restart gitea
docker logs -f gitea
