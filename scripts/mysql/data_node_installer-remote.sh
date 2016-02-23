#!/bin/bash -e

PACKAGE=#PACKAGE
DESC=#DESC

WORKDIR=/usr/local/mysql

tar -C /usr/local -xzvf ${DESC}/${PACKAGE}
ln -s /usr/local/${PACKAGE%.tar.gz} ${WORKDIR}

BINDIR=/usr/local/bin

cp ${WORKDIR}/bin/ndbd ${BINDIR}/ndbd
cp ${WORKDIR}/bin/ndbmtd ${BINDIR}/ndbmtd

chmod +x ${BINDIR}/ndb*

echo -e "\nThe data directory on each machine hosting a data node is /usr/local/mysql/data."
