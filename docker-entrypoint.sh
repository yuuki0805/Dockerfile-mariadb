#!/bin/sh

# Initialize
tempfile=`mktemp`
cat << EOF > $tempfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}');
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

/usr/bin/mariadbd --user=mysql --bootstrap < $tempfile
rm -f $tempfile

# 
for f in /docker-entrypoint-initdb.d/*; do
  case "$f" in
    *.sh)
      if [ -x "$f" ]; then
        echo "$0: running $f"; "$f"
      else
        echo "$0: sourcing $f"; . "$f"
      fi
      ;;
    *.sql)    echo "$0: running $f"; /usr/bin/mysqld --user=mysql --bootstrap < "$f"; echo ;;
    *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | /usr/bin/mysqld --user=mysql --bootstrap < "$f"; echo ;;
    *)        echo "$0: ignoring or entrypoint initdb empty $f" ;;
  esac
  echo
done

# execute
exec "$@"
