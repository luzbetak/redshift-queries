Redshift Cluster Deep Dive Queries
==================================


### Schema queries
* Number of schema
* Number of tables
* Top 10 largest tables by number of rows
* Number of tables DIST-ALL. DIST-EVEN, DIST KEY


### WLM related queries
* Number of queues, slots, concurrency scaling  enables..
* QMR rules
* Query Priorities Info


### Grand Unified Scheme (GUC)
* What are all available gucs
* What are the current guc values


### Workload Analysis
* Queue length, queue min/max times 
* Number of queries run per queue aggregated to the  hour in every queue
* Number of queries run per queue aggregated to the  hour that took more than x sec
* Number of times a specific query was run in a day  (MD5?)
* Breakout of DML vs DDL vs SELECT queries in a day
* Number of queries that hit results cache every hour in a day for a given day


### Loading Analysis


### Spectrum Analysis


### Data Distribution on Slices
* Display Slices

