#!/bin/bash

#---step1---
install_path='/home/soumik/SOUMIKD/IITB/Class_notes/sem_3/CS_631_RDBMS/Assignments/Final_project/postgres_codebase'
export POSTGRES_SRCDIR="${install_path}/postgresql"
export POSTGRES_INSTALLDIR="${POSTGRES_SRCDIR}/install"
export LD_LIBRARY_PATH=${POSTGRES_INSTALLDIR}/lib:${LD_LIBRARY_PATH}
export PATH=${POSTGRES_INSTALLDIR}/bin:${PATH}
export PGDATA=${POSTGRES_INSTALLDIR}/data
export PGDATA_FD=${POSTGRES_INSTALLDIR}/data_fd

#--step2--
# Stop the postgres server:
# ${POSTGRES_INSTALLDIR}/bin/pg_ctl stop

#---step3---
# in '{POSTGRES_SRCDIR}/configure' replace -O2 in CFlags by -O0  in all occurrences except BITCODE_CFLAGS (there are about 6 places)
cd ${POSTGRES_SRCDIR}
#make distclean
#./configure --prefix=${POSTGRES_INSTALLDIR} --enable-debug
#export enable_debug=yes

#---step4---
# Packages needed before: sudo apt install libreadline6-dev zlib1g-dev bison flex
# for installing libread : https://askubuntu.com/questions/194523/how-do-i-install-gnu-readline
# make uninstall
make all| tee gmake.out
make install | tee gmake_install.out

# Eclipse entry to run 'install/bin/postgres' in 'single' user mode with particular DBs:
# --single -D /home/soumik/SOUMIKD/IITB/Class_notes/sem_3/CS_631_RDBMS/Assignments/Final_project/postgres_codebase/postgresql/install/data localdb
# --single -D /home/soumik/SOUMIKD/IITB/Class_notes/sem_3/CS_631_RDBMS/Assignments/Final_project/postgres_codebase/postgresql/install/data foreigndb

# After code change ti run and test postgres server:
## ${POSTGRES_INSTALLDIR}/bin/postgres -D ${PGDATA}				# Runs the server
## ${POSTGRES_INSTALLDIR}/bin/psql -h /tmp -d localdb -U soumik -p 5432		# Connects to the DB at server 
## ${POSTGRES_INSTALLDIR}/bin/psql -h /tmp -d foreigndb -U soumik -p 5432	# Connects to the DB at server
