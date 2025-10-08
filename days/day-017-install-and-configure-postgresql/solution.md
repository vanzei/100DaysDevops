## Connect to Postgres

sudo -u postgres psql


## Create DB User
```
CREATE USER kodekloud_sam WITH PASSWORD 'ksH85UJjhb';
```

## Create Database
```
CREATE DATABASE kodekloud_db8;
```

## GRANT Permission 
```

GRANT ALL PRIVILEGES ON DATABASE kodekloud_db8 TO kodekloud_sam;

```

## Test

```
psql -h localhost -U kodekloud_sam -d kodekloud_db8
```