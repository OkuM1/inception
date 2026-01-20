FROM debian:bullseye

RUN apt update -y

RUN apt upgrade -y

RUN apt install -y mariadb-server bash

RUN apt clean

RUN rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/maria.sh /usr/local/bin/maria.sh

RUN chmod +x /usr/local/bin/maria.sh

CMD ["/usr/local/bin/maria.sh"]