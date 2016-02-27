#!/bin/bash

PACKAGE=#PACKAGE
DEST=#DEST

apt-get install libaio1

groupadd mysql
useradd -g mysql -s /bin/false mysql

WORKDIR=/usr/local/mysql

tar -C /usr/local -xzvf ${DEST}/${PACKAGE}
ln -s /usr/local/${PACKAGE%.tar.gz} ${WORKDIR}

${WORKDIR}/scripts/mysql_install_db --user=mysql --basedir=${WORKDIR} --datadir=${WORKDIR}/data

chown -R root ${WORKDIR}
chown -R mysql ${WORKDIR}/data
chgrp -R mysql ${WORKDIR}

cp ${WORKDIR}/support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
update-rc.d mysql defaults
