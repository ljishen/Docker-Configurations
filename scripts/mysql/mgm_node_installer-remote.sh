#!/bin/bash -e

PACKAGE=#PACKAGE
DESC=#DESC

WORKDIR=/usr/local/mysql

tar -C /usr/local -xzvf ${DESC}/${PACKAGE}
ln -s /usr/local/${PACKAGE%.tar.gz} ${WORKDIR}

BINDIR=/usr/local/bin

cp ${WORKDIR}/bin/ndb_mgm* ${BINDIR}

chmod +x ${BINDIR}/ndb_mgm*

echo -e "\nDone!"
