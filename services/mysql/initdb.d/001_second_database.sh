#!/bin/sh
echo "CREATE DATABASE IF NOT EXISTS \`"$MYSQL_DATABASE_TEST"\` ;" | "${mysql[@]}"
echo "GRANT ALL ON \`"$MYSQL_DATABASE_TEST"\`.* TO '"$MYSQL_USER"'@'%' ;" | "${mysql[@]}"
echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"

#"${mysql[@]}" < /docker-entrypoint-initdb.d/second_database.sql_
