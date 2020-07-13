Redshift Cluster Health Check
=============================

## Cluster

* XX nodes of `<type>`. 
* Space used is <well | poorly> distributed overall.
* Space used is skewed with Node #0 at <value>% and other nodes around <value>%. See notes below in **"Skewed Tables"**

## Databases & Schemas

* Relatively little data in the `public` schema, which users have access to by default.
* There are a large number of schemas containing significant data. 
* It can be challenging to safely manage user access permissions for so many schemas.

## Large Tables

* 2 versions of the table `<duplicate>` exist. Very skewed due to using an apparent date value as the distribution key. 
* Many large tables have no compression. Space used by these tables and query times against them can be greatly improved with compression.
* Recommend running `ANALYZE COMPRESSION` periodically on all large tables to verify settings.
* Many large tables are using `INTERLEAVED` sort keys. This sort key type is unsuitable for regularly updated tables.
* To perform well `INTERLEAVED` sort keys must be re-indexed when their data changes using `VACUUM REINDEX`.
* **Recommend using a _normal_ sort key unless you have _confirmed_ that an `INTERLEAVED` key is appropriate.**
* [Refer to our "Advanced Table Design Playbook" for help on when `INTERLEAVED` will work best.](https://aws.amazon.com/blogs/big-data/amazon-redshift-engineerings-advanced-table-design-playbook-compound-and-interleaved-sort-keys/)
* Many large tables contain 1 or more `VARCHAR(MAX)` columns. 
* These columns are expensive during all phases of the query as 65k bytes of memory must be allocated for each row.
* **Recommend always using the minimum possible `VARCHAR` size.**
* The table `<unsorted>` is very unsorted. The table should be vacuumed to resort the data.
* Many large tables with sort keys are very unsorted. For example `<table_1>`,`<table_2>`, and `<table_3>`
* **Recommend `VACUUM`-ing tables regularly to maximize the effectiveness of sort keys.**
* `VACUUM`ing *very large* tables which are *very unsorted* may very slow and resource intensive. [Use a deep copy strategy in this case.](http://docs.aws.amazon.com/redshift/latest/dg/performing-a-deep-copy.html)
* Many large tables use an EVEN distribution but have no sort key. For example `<table_1>`,`<table_2>`, and `<table_3>`
* Queries against these tables will require a large amount of data movement during execution.
* **Recommend using a sort key to reduce disk reads and a distribution key if possible.**
* Many large tables have compression on their first sort key column. 
* This causes read amplification. More blocks than necessary are read from disk for all other columns.
* Example tables; ``, ``, ``, ``, ``, ``
* **Recommend that all sort keys have their *first* column with NO compression or `ENCODE raw`**
* 11 of the 25 largest tables have no sort key.
* Queries against these tables will require a large amount of reading from disk.
* Typically the primary timestamp or date column works best candidate the first sortkey.
* Other columns that frequently used as query predicates can be also be added (up to 5).
* **Recommend using common query predicate columns as a sort key to minimize disk reads.**

## Skewed Tables

* A number of large tables use a column `<dist-col>` as the distribution key. This column appears to contain a large number of `NULL` values.
* These `NULL` values are all being located on compute node #0 causing siginificant storage skew.
* Any queries which don't explicitly exclude `NULL` will have to do much more work on this node.
* For example, the table `<table_1>` has more than <row-count> `NULL` values in `<dist-col>`.
* **Recommend changing the distribution key to another column that participates in joins with other tables.**
* A number of large tables use a column `invc_dt DATE` as the distribution key. 
* Using `DATE` (and to a lesser extent `TIMESTAMP`) columns is a bad practice for Redshift
* Queries which are limited to a single day will be executed on just one slice of the cluster.
* `UPDATE`/`INSERT`/`DELETE` queries that touch only a single day will also use just one slice of the cluster.
* **Strongly recommend using a distribution key column that participates in joins with other tables.**
* Many customers find that an account or customer identifier works best as the distribution key.

## Unused Tables

* Tables `<table_1>`,`<table_2>`, and `<table_3>` are never scanned. No user queries are hitting these tables.
* Consider offloading infrequently accessed data to S3 in a format that can be queried by Redshift Spectrum.

## Candidates for DISTSTYLE ALL ==

* A number of tables have very few rows per slice. These are good candidates for converting to `DISTSTYLE ALL`.
* Recommend addressing this after moving to `dc2.8xlarge`.


## Alerts

* Over X,000 queries using tables with missing or stale statistics. 
* **Recommend adding `ANALYZE` or `ANALYZE PREDICATE COLUMNS` at the end of loading processes.**
* Queries using `<table_1>`,`<table_2>`, and `<table_3>` frequently scan a large number of rows but return very few to the next step. 
* **Recommend adding frequently used `WHERE` criteria to the sort key.**
* Queries using `<table_1>`,`<table_2>`, and `<table_3>` frequently send many rows to all other nodes. 
* **If possible, recommend that large tables being joined have the same distribution key.**
* Queries using `<table_1>`,`<table_2>`, and `<table_3>` frequently scan a large number of blocks that have been deleted. 
* **Recommend running `VACUUM DELETE ONLY` regularly to avoid scanning deleted data and reclaim space.**

## Usage Pattern ==

* `COPY`, `VACUUM` and `UPDATE`/`INSERT`/`DELETE` workloads appear to run 24/7, although they slow down during the day.
* Cursor usage (typically from tools like Tableau, Microstrategy, etc.) peaks in the 13:00 hour.
* A large number of very short duration `SELECT` queries are issue in the 04:00 hour (which brings down the average duration).


## Workload Management ==

* We generally recommend fewer than 15 total concurrency slots because each slot gets a fixed memory allocation. 
* **Maximum throughput (queries per hour) is typically seen with 15 total slots or less.**
* Current settings seem fairly reasonable now that "Service class #3" has been reduced to 19 slots.
* **Recommend investigating our Query Monitoring Rules to allow additional control of query resource consumption.**

* The following suggestions are based on observing peak queueing queries per hour in the WLM history 
* `Service class #n <(user group: group)>` is **heavily contested**. <value> slots allocated with <value> queries commonly running. Recommend <value> slots with <value>% of memory.
* `Service class #n <(user group: group)>` has <**far too much memory**> allocated. Recommend <value> slots and <value>% of memory
* `Service class #n <(user group: group)>` does not have enough memory. Recommend <value> slots and <value>% of memory.
* `Service class #n <(user group: *)>` does not have enough memory. Recommend <value> slots and <value>% of memory.
* `Service class #n <(querytype: any)>` has too much memory. <**Very few queries run in this queue**>. Recommend <value> slots <value>% of memory.
* `Service class #n <(querytype: any)>` is largely unused. Queries not seen in many hours. Recommend <value> slots and <value>% of memory.
* Consider levaraging dynamic WLM properties to change memory allocation to favor users during the day and ETL overnight.

## Load Performance

* Most loads involve multiple files, which is a best practice.
* Files being loaded do not appear to be compressed. GZIP'ed files can be loaded by Redshift 3-5x faster.
* `COPY` commands are not being issued with `COMPUPDATE OFF` or `STATUPDATE OFF`. These activities can account for as much as 2/3rds of the total `COPY` time.


## Reference:
[https://w.amazon.com/bin/view/Harrjose/CustomerReviewTemplate/](https://w.amazon.com/bin/view/Harrjose/CustomerReviewTemplate/)
