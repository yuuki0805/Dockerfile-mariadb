FROM alpine:latest
RUN apk add --no-cache mariadb && \
    mkdir /run/mysqld && chown mysql:mysql /run/mysqld && \
    mariadb-install-db --user=mysql --ldata=/var/lib/mysql && \
    sed -i 's|skip-networking|#skip-networking|g' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i 's|#bind-address=0.0.0.0|bind-address=0.0.0.0|g' /etc/my.cnf.d/mariadb-server.cnf && \
    touch /var/log/mysqld.log && \
    chown mysql:mysql /var/log/mysqld.log && \
    sed -i '/^\[server\]$/a log-error=\/var\/log\/mysqld.log' /etc/my.cnf.d/mariadb-server.cnf && \
    mkdir /docker-entrypoint-initdb.d

EXPOSE 3306

VOLUME /var/lib/mysql/

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/bin/mariadbd", "--user=mysql"]
