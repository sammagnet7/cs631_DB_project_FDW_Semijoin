#!/bin/bash
# git clone -b REL_16_STABLE https://git.postgresql.org/git/postgresql.git

#---step1---
install_path='/home/soumik/SOUMIKD/IITB/Class_notes/sem_3/CS_631_RDBMS/Assignments/Final_project/postgres_codebase'

export POSTGRES_SRCDIR="${install_path}/postgresql"
export POSTGRES_INSTALLDIR="${POSTGRES_SRCDIR}/install"
export LD_LIBRARY_PATH=${POSTGRES_INSTALLDIR}/lib:${LD_LIBRARY_PATH}
export PATH=${POSTGRES_INSTALLDIR}/bin:${PATH}
export PGDATA=${POSTGRES_INSTALLDIR}/data
export PGDATA_FD=${POSTGRES_INSTALLDIR}/data_fd

#---step2---
# Stop the postgres server:
${POSTGRES_INSTALLDIR}/bin/pg_ctl stop
# In '{POSTGRES_SRCDIR}/configure' replace -o2 in CFlags by -o0  in all occurrences except BITCODE_CFLAGS (there are about 6 places)
cd ${POSTGRES_SRCDIR}
make distclean
./configure --prefix=${POSTGRES_INSTALLDIR} --enable-debug
export enable_debug=yes

#---step3---
# Packages needed before: sudo apt install libreadline6-dev zlib1g-dev bison flex
# for installing libread : https://askubuntu.com/questions/194523/how-do-i-install-gnu-readline
make uninstall
make world| tee gmake.out
make install | tee gmake_install.out

#---step4---
# create a new PostgreSQL database cluster which creates all postgres specific confiration files like pg_hba.conf, postgresql.conf etc.
${POSTGRES_INSTALLDIR}/bin/initdb -D ${PGDATA}
${POSTGRES_INSTALLDIR}/bin/initdb -D ${PGDATA_FD}

#---step5---
# change any configuration from ${POSTGRES_INSTALLDIR}/data/pg_hba.conf or ${POSTGRES_INSTALLDIR}/data/postgresql.conf
# Run the postgres server
 ${POSTGRES_INSTALLDIR}/bin/pg_ctl -D $PGDATA -l logfile -o "-p 5432" start
 ${POSTGRES_INSTALLDIR}/bin/pg_ctl -D $PGDATA_FD -l logfile -o "-p 5433" start
# OR
# ${POSTGRES_INSTALLDIR}/bin/postgres -D ${PGDATA} -p 5432
# ${POSTGRES_INSTALLDIR}/bin/postgres -D ${PGDATA_FD} -p 5433

#---step6---
# cretae DBs
${POSTGRES_INSTALLDIR}/bin/createdb -p 5432 localdb
${POSTGRES_INSTALLDIR}/bin/createdb -p 5433 foreigndb

#---step7---
# client program
# ${POSTGRES_INSTALLDIR}/bin/psql -h /tmp -d localdb -U soumik -p 5432	# Default user postgres took from bash user running the initdb command
# ${POSTGRES_INSTALLDIR}/bin/psql -h /tmp -d foreigndb -U soumik -p 5432
## Some sql commands:
###	\l
###	select datname from pg_catalog.pg_database;
###	select USER, CURRENT_USER,CURRENT_ROLE;
###	 SELECT current_database();
###	

#---step8---
# Stop the server
 ${POSTGRES_INSTALLDIR}/bin/pg_ctl -D ${PGDATA} stop
 ${POSTGRES_INSTALLDIR}/bin/pg_ctl -D ${PGDATA_FD} stop


#---step9---
# run postgresql in single user mode (very useful for debugging when you modify the sources)
# Exit: cntrl+D
# postgres --single -D ${PGDATA} localdb
# postgres --single -D ${PGDATA} foreigndb

# Eclipse entry to run 'install/bin/postgres' in 'single' user mode with particular DBs:
# --single -D /home/soumik/SOUMIKD/IITB/Class_notes/sem_3/CS_631_RDBMS/Assignments/Final_project/postgres_codebase/postgresql/install/data localdb
# --single -D /home/soumik/SOUMIKD/IITB/Class_notes/sem_3/CS_631_RDBMS/Assignments/Final_project/postgres_codebase/postgresql/install/data foreigndb

# After code change to run and test postgres server:
## ${POSTGRES_INSTALLDIR}/bin/postgres -D ${PGDATA}				# Runs the server
## ${POSTGRES_INSTALLDIR}/bin/psql -h /tmp -d localdb -U soumik -p 5432		# Connects to the DB at server 
## ${POSTGRES_INSTALLDIR}/bin/psql -h /tmp -d foreigndb -U soumik -p 5433	# Connects to the DB at server


