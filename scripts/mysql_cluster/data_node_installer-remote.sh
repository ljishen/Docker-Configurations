#!/bin/bash -e

PACKAGE=#PACKAGE
DEST=#DEST

WORKDIR=/usr/local/mysql

tar -C /usr/local -xzvf ${DEST}/${PACKAGE}
ln -s /usr/local/${PACKAGE%.tar.gz} ${WORKDIR}

BINDIR=/usr/local/bin

cp ${WORKDIR}/bin/ndbd ${BINDIR}/ndbd
cp ${WORKDIR}/bin/ndbmtd ${BINDIR}/ndbmtd

chmod +x ${BINDIR}/ndb*

echo -e "\nDone!"
echo "The data directory on each machine hosting a data node is /usr/local/mysql/data."
