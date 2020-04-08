FROM debian:stretch-slim
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
	&& apt-get -y dist-upgrade \
	&& apt-get -y install build-essential busybox-syslogd catdoc cron curl default-libmysqlclient-dev libssl-dev libtre-dev libwrap0-dev libzip-dev mysql-client nginx php-curl php-fpm php-gd php-ldap php-memcache php-mysql php-pdo poppler-utils python-mysqldb sphinxsearch supervisor sysstat tnef unrtf
RUN groupadd piler \
	&& useradd -g piler -m -s /bin/sh -d /var/piler piler \
	&& usermod -L piler \
	&& chmod 755 /var/piler \
	&& mkdir xlhtml \
	&& curl -L https://bitbucket.org/jsuto/piler/downloads/xlhtml-0.5.1-sj-mod.tar.gz | tar xvz --strip=1 -C xlhtml \
	&& cd xlhtml \
	&& ./configure \
	&& make \
	&& make install \
	&& cd .. \
	&& mkdir piler \
	&& curl -L https://bitbucket.org/jsuto/piler/downloads/piler-1.3.5.tar.gz | tar xvz --strip=1 -C piler \
	&& cd piler \
	&& ./configure --localstatedir=/var --with-database=mysql --enable-tcpwrappers \
	&& make \
	&& make install \
	&& make key \
	&& cp piler.key /usr/local/etc/piler \
	&& chgrp piler /usr/local/etc/piler/piler.key \
	&& chmod 640 /usr/local/etc/piler/piler.key \
	&& ldconfig \
	&& mkdir -p /etc/sphinxsearch \
	&& ln -s /usr/local/etc/piler/sphinx.conf /etc/sphinxsearch \
	&& service php7.0-fpm start
COPY rootfs /
RUN crontab /tmp/piler.cron
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
EXPOSE 25/tcp
EXPOSE 80/tcp
