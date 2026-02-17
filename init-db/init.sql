CREATE DATABASE sso_db;
CREATE DATABASE compro_db;

-- Gitea database and user
-- Password should match GITEA_DB_PASSWORD env var
CREATE DATABASE gitea_db;
CREATE USER gitea_user WITH ENCRYPTED PASSWORD 'WaduhAngkongNangLai11221212';
GRANT ALL PRIVILEGES ON DATABASE gitea_db TO gitea_user;