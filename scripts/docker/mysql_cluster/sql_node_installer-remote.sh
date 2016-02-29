#!/bin/bash

# We are not putting -e to the first line because we want to
# pass all commands even if the group "mysql" existed.

PACKAGE=#PACKAGE
DEST=#DEST

apt-get install libaio1

groupadd mysql
useradd -g mysql -s /bin/false mysql

WORKDIR=/usr/local/mysql

tar -C /usr/local -xzvf ${DEST}/${PACKAGE}
ln -s /usr/local/${PACKAGE%.tar.gz} ${WORKDIR}

${WORKDIR}/scripts/mysql_install_db --user=mysql --basedir=${WORKDIR} --datadir=${WORKDIR}/data

mkdir -p /var/lib/mysql/
chown -R mysql /var/lib/mysql/
chown -R root ${WORKDIR}
chown -R mysql ${WORKDIR}/data
chgrp -R mysql ${WORKDIR}

cp ${WORKDIR}/support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
update-rc.d mysql defaults

echo -e "\nYou can start the MySQL daemon with:
  cd . ; /usr/local/mysql/bin/mysqld_safe &"
