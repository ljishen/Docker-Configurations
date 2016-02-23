#!/bin/bash

PACKAGE=#PACKAGE
DESC=#DESC

apt-get install libaio1

groupadd mysql
useradd -g mysql -s /bin/false mysql

WORKDIR=/usr/local/mysql

tar -C /usr/local -xzvf ${DESC}/${PACKAGE}
ln -s /usr/local/${PACKAGE%.tar.gz} ${WORKDIR}

${WORKDIR}/scripts/mysql_install_db --user=mysql --basedir=${WORKDIR}

chown -R root ${WORKDIR}
chown -R mysql ${WORKDIR}/data
chgrp -R mysql ${WORKDIR}

cp ${WORKDIR}/support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
update-rc.d mysql defaults
