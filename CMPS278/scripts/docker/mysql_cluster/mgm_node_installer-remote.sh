#!/bin/bash -e

PACKAGE=#PACKAGE
DEST=#DEST

WORKDIR=/usr/local/mysql

tar -C /usr/local -xzvf ${DEST}/${PACKAGE}
ln -s /usr/local/${PACKAGE%.tar.gz} ${WORKDIR}

BINDIR=/usr/local/bin

cp ${WORKDIR}/bin/ndb_mgm* ${BINDIR}

chmod +x ${BINDIR}/ndb_mgm*

echo -e "\nPlease execute the following commands:"
echo "ndb_mgmd -f /var/lib/mysql-cluster/config.ini"
echo "ndb_mgm"
echo "SHOW"
