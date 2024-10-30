1. Title: Foreign Data Wrapper: Supporting Semijoins

2. Team:
- Soumik Dutta (23m0826)
- Sm Arif Ali (23m0822)

3. Brief Description:

Motivation:  
PostgreSQL provides robust support for querying foreign data through the Foreign Data Wrapper (FDW). However, the default behavior of pulling entire foreign relations into the local system during join operations can result in substantial network overhead. The motivation behind this project is to reduce the amount of data transferred between sites when performing distributed joins. This is achieved by implementing semijoin optimization, where only the relevant tuples from foreign relations are fetched, thereby improving the performance of queries that involve joins across multiple sites.



Plan Outline:  
Our project aims to extend PostgreSQL’s FDW mechanism to support semijoin operations. This will be done by implementing the following steps:

1. Semijoin Detection: Modify the query planner to detect opportunities where semijoins can optimize foreign table joins.
2. Data Transfer Optimization: Implement logic to send only the projected columns of the local relation to the foreign server, either directly or using a Bloom filter to minimize the data sent.
3. Bloom Filter Implementation: Create and transmit a Bloom filter from the local server to the foreign server, allowing the foreign server to filter out tuples that don’t match the join condition.
4. Final Join at the Local Site: After fetching the filtered tuples from the foreign site, perform the final join locally, eliminating any false positives if a Bloom filter was used.



This project will result in more efficient handling of distributed queries, especially in scenarios where bandwidth is constrained, leading to significant performance improvements for cross-site joins.
