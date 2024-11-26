# cs631_DB_project_FDW_Semijoin

## Semijoin Strategy

### A. Strategy to accomplish expression r1 ⋈ r2

1. Compute `temp1 ← ΠR1 ∩ R2 (r1)` at `S1`.
2. Ship `temp1` from `S1` to `S2`.
3. Compute `temp2 ← r2 ⋈ temp1` at `S2`.
4. Ship `temp2` from `S2` to `S1`.
5. Compute `r1 ⋈ temp2` at `S1`. The resulting relation is the same as `r1 ⋈ r2`.

### B. Semijoin Strategy Denoted r1 ⋉ r2

1. `r1 ⋉ r2` selects those tuples of relation `r1` that contributed to `r1 ⋈ r2`.
2. Natural semijoin of `r1` with `r2`, denoted `r1 ⋉ r2 ≈ ΠR1 (r1 ⋈ r2)`
3. Theta semijoin of `r1` with `r2`, denoted `r1 ⋉θ r2 ≈ ΠR1 (r1 ⋉θ r2)`

> **Note**: This strategy is particularly advantageous when relatively few tuples of `r2` contribute to the join. The cost savings of the strategy result from having to ship only `(r2 ⋉ r1)`, rather than all of `r2`, to `S1`.

### C. Further Optimization Using Bloom Filters

The overhead of sending `temp1` tuples from `S1` to `S2` can be reduced as follows:

1. A Bloom filter with a bitmap `b` of size `m`, initialized with all bits set to `0`, is used.
2. Join attributes of each tuple of `r1` are hashed to a value in the range `0 ... (m - 1)`, and the corresponding bit of `b` is set to 1.
3. This bitmap `b`, which is much smaller than the relation `r1`, can now be sent to `S2`.
4. The same hash function is computed on the join attributes of each tuple of `r2` at `S2`.
5. If the corresponding bit is set to 1 in `b`, that `r2` tuple is accepted, added to the `temp1` relation; otherwise, it is rejected.
6. The `temp1` relation, which is a superset of or equal to `(r2 ⋉ r1)`, is sent to site `S1`.
7. Join `(r1 ⋈ temp1)` is then computed at site `S1` to get the required join result.

> **Note**: False positives may result in extra tuples in `temp1` that are not present in `(r2 ⋉ r1)`, but such tuples would be eliminated by the join. To keep the probability of false positives low:
>
> - The number of bits in the Bloom filter is usually set to a few times the estimated number of distinct join attribute values.
> - It is possible to use `k` independent hash functions for the Bloom filter.

### D. For Joins of Several Relations

The semijoin strategy can be extended to a series of semijoin steps.

---

## Project Setup

> **Postgres Codebase**: `git clone -b REL_16_STABLE https://git.postgresql.org/git/postgresql.git`
> **Version**: REL_16_STABLE

### Setting Up Foreign Data Wrapper

1. Start PostgreSQL server:  
   `${POSTGRES_INSTALLDIR}/bin/postgres -D ${PGDATA} -p 5432`
   `${POSTGRES_INSTALLDIR}/bin/postgres -D ${PGDATA_FD} -p 5433`
   
2. Create 2 databases:  
   `${POSTGRES_INSTALLDIR}/bin/createdb -p 5432 localdb`  
   `${POSTGRES_INSTALLDIR}/bin/createdb -p 5433 foreigndb`

3. Login to foreigndb:  
   `${POSTGRES_INSTALLDIR}/bin/psql -h /tmp -d foreigndb -U soumik -p 5433`

   ```sql
   CREATE TABLE takes (
       ID VARCHAR(5), 
       course_id VARCHAR(8),
       sec_id VARCHAR(8), 
       semester VARCHAR(6),
       year NUMERIC(4, 0),
       grade VARCHAR(2),
       PRIMARY KEY (ID, course_id, sec_id, semester, year)
   );

   INSERT INTO takes VALUES ('65901', '401', '1', 'Fall', 2003, 'C-');
   INSERT INTO takes VALUES ('24932', '802', '1', 'Spring', 2003, 'B-');
   -- Additional insert statements...
   INSERT INTO takes VALUES ('89132', '875', '1', 'Spring', 2005, 'C ');
   ```

4. Modify ACL in pg_hba.conf as needed.

5. Install postgres_fdw extension:
   ```bash
   cd {POSTGRES_SRCDIR}/contrib/postgres_fdw
   make
   make install
   ```

6. Login to localdb:  
   `${POSTGRES_INSTALLDIR}/bin/psql -h /tmp -d localdb -U soumik -p 5432`

   ```sql
   CREATE TABLE course (
       course_id VARCHAR(8), 
       title VARCHAR(50), 
       dept_name VARCHAR(20),
       credits NUMERIC(2, 0) CHECK (credits > 0),
       year numeric(4,0),
       PRIMARY KEY (course_id)
   );

   INSERT INTO course VALUES ('787', 'C  Programming', 'Mech. Eng.', 4, 2001);
   INSERT INTO course VALUES ('238', 'The Music of Donovan', 'Mech. Eng.', 3, 2002);
   -- Additional insert statements...
   INSERT INTO course VALUES ('780', 'Geology', 'Psychology', 3, 2003);

   CREATE EXTENSION IF NOT EXISTS postgres_fdw;

   CREATE SERVER fdw_server FOREIGN DATA WRAPPER postgres_fdw
   OPTIONS (dbname 'foreigndb', host '127.0.0.1', port '5433');

   CREATE USER MAPPING FOR soumik SERVER fdw_server OPTIONS (user 'soumik');

   GRANT USAGE ON FOREIGN SERVER fdw_server TO soumik;

   IMPORT FOREIGN SCHEMA "public" LIMIT TO (takes) FROM SERVER fdw_server INTO public;

   -- Run test join query
   EXPLAIN ANALYZE
   SELECT COUNT(*)
   FROM course c
   WHERE EXISTS (SELECT * FROM takes t WHERE t.course_id = c.course_id);
   ```

> **Reference**: [Towards Data Science Guide on Setting up Foreign Data Wrapper in PostgreSQL](https://towardsdatascience.com/how-to-set-up-a-foreign-data-wrapper-in-postgresql-ebec152827f3)

7. Launch.json to setup vscode:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(lldb) Launch Single",
            "type": "lldb",
            "request": "launch",
            "program": "/home/soumik/SOUMIKD/IITB/Class_notes/sem_3/CS_631_RDBMS/Assignments/Final_project/postgres_codebase/postgresql/install/bin/postgres",
            "args": ["--single", "localdb"],
            "cwd": "/home/soumik/SOUMIKD/IITB/Class_notes/sem_3/CS_631_RDBMS/Assignments/Final_project/postgres_codebase/postgresql",
            "env": {
                "PGDATA": "/home/soumik/SOUMIKD/IITB/Class_notes/sem_3/CS_631_RDBMS/Assignments/Final_project/postgres_codebase/postgresql/install/data"
            },
            "externalConsole": true,
            "stopOnEntry": false
        }
    ]
}
```

8. 