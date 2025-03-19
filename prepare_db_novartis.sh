#!/bin/bash

# set variables

BI_DB=$1
USER_DW_DB=$2
DB_HOST=$3
PORT=$4
BI_DB_USER=$5
BI_PASSWORD="$6"
DW_DB_USER=$7
DW_PASSWORD="$8"

BLACK_BI_DB="${BI_DB}_black"
BLACK_USER_DW_DB="${USER_DW_DB}_black"


export PGPASSWORD="$BI_PASSWORD"

for tool in psql pg_dump
do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool command not found. Please make sure Postgres is installed and psql is available."
        exit 1
    else
        echo "$tool command is available."
    fi
done

#### create database black bi database
psql --dbname=$BI_DB --username=$BI_DB_USER --port=$PORT --host=$DB_HOST -c "CREATE DATABASE $BLACK_BI_DB; "
psql --dbname=$BI_DB --username=$BI_DB_USER --port=$PORT --host=$DB_HOST -c "ALTER DATABASE $BLACK_BI_DB OWNER TO $BI_DB_USER;"

if [ $? -eq 0 ]; then
    echo "Database $BLACK_BI_DB has been successfully created."
else
    echo "Failed to create database $BLACK_BI_DB."
    exit 1
fi

#### BI database schema migration
pg_dump  --dbname=$BI_DB --username=$BI_DB_USER --port=$PORT --host=$DB_HOST --schema-only > bi_schema.sql
if [ $? -eq 0 ]; then
        echo "dump $BI_DB schema has been successfully."
    else
        echo "Failed to dump database $BI_DB."
        exit 1
fi


psql  --dbname=$BLACK_BI_DB --username=$BI_DB_USER --port=$PORT --host=$DB_HOST -f  bi_schema.sql
if [ $? -eq 0 ]; then
        echo "create $BLACK_BI_DB schema has been successfully."
    else
        echo "Failed to create tables in database $BLACK_BI_DB."
        exit 1
fi

#### BI database table django_migrations data migration
pg_dump  --dbname=$BI_DB --username=$BI_DB_USER --port=$PORT --host=$DB_HOST -a --table=public.django_migrations  > bi_migration_data.sql
if [ $? -eq 0 ]; then
        echo "dump django_migrations table data has been successfully."
    else
        echo "Failed to dump database $BI_DB."
        exit 1
fi


psql  --dbname=$BLACK_BI_DB --username=$BI_DB_USER --port=$PORT --host=$DB_HOST -f  bi_migration_data.sql
if [ $? -eq 0 ]; then
        echo "migrate table django_migrations to $BLACK_BI_DB  has been successfully."
    else
        echo "Failed to migrate tables to database $BLACK_BI_DB."
        exit 1
fi



export PGPASSWORD="$DW_PASSWORD"

#### create database black user dw database
psql --dbname=$USER_DW_DB --username=$DW_DB_USER --port=$PORT --host=$DB_HOST -c "CREATE DATABASE $BLACK_USER_DW_DB; "
psql --dbname=$USER_DW_DB --username=$DW_DB_USER --port=$PORT --host=$DB_HOST -c "ALTER DATABASE $BLACK_USER_DW_DB OWNER TO $DW_DB_USER;"

if [ $? -eq 0 ]; then
    echo "Database $BLACK_USER_DW_DB has been successfully created."
else
    echo "Failed to create database $BLACK_USER_DW_DB."
    exit 1
fi


#### USER_DW database schema migration
pg_dump  --dbname=$USER_DW_DB --username=$DW_DB_USER --port=$PORT --host=$DB_HOST --schema-only > user_dw_schema.sql
if [ $? -eq 0 ]; then
        echo "dump $USER_DW_DB schema has been successfully."
    else
        echo "Failed to dump database $USER_DW_DB."
        exit 1
fi


psql  --dbname=$BLACK_USER_DW_DB --username=$DW_DB_USER --port=$PORT --host=$DB_HOST -f  user_dw_schema.sql
if [ $? -eq 0 ]; then
        echo "create $BLACK_USER_DW_DB schema has been successfully."
    else
        echo "Failed to create tables in database $BLACK_USER_DW_DB."
        exit 1
fi


pg_dump  --dbname=$USER_DW_DB --username=$DW_DB_USER --port=$PORT --host=$DB_HOST --table=public.\"Product\" -a > user_dw_Product.sql
if [ $? -eq 0 ]; then
        echo "dump table Product has been successfully."
    else
        echo "Failed to dump table Product"
        exit 1
fi


psql  --dbname=$BLACK_USER_DW_DB --username=$DW_DB_USER --port=$PORT --host=$DB_HOST --table=public.\"Product\" -f  user_dw_Product.sql
if [ $? -eq 0 ]; then
        echo "table Product has been loaded successfully."
    else
        echo "Failed to load table Product in database $BLACK_USER_DW_DB."
        exit 1
fi

pg_dump  --dbname=$USER_DW_DB --username=$DW_DB_USER --port=$PORT --host=$DB_HOST --table=public.dim_calendar -a > user_dw_dim_calendar.sql
if [ $? -eq 0 ]; then
        echo "dump table dim_calendar has been successfully."
    else
        echo "Failed to dump table dim_calendar."
        exit 1
fi


psql  --dbname=$BLACK_USER_DW_DB --username=$DW_DB_USER --port=$PORT --host=$DB_HOST --table=public.dim_calendar -f  user_dw_dim_calendar.sql
if [ $? -eq 0 ]; then
        echo "table dim_calendar has been loaded successfully."
    else
        echo "Failed to load table dim_calendar in database $BLACK_USER_DW_DB."
        exit 1
fi
