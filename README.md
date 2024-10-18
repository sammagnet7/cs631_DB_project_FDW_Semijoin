# cs631_DB_project_FDW_Semijoin
This is the final DBMS course project: Implements Semijoin optimization for FDW joins.

Task given by sir:
Foreign Data Wrapper: supporting semijoins				
PostgreSQL allows a relation on site b to be defined as a foreign relation on site A, and selects on a foreign relation at A can be pushed to site B.  The goal here when join relations from the two sides,  to push a semi-join to B and fetch only the required tuples from B. First task then is to implement semijoin		

Read up on semijoin optimization in distributed databases from Chapter 22 slides.  Then figure out how to use existing foreign relations support in PostgreSQL to implement semijoins.	You can talk with Anant Utgikar (204050001@iitb.ac.in) who is a research scholar for help on this project
