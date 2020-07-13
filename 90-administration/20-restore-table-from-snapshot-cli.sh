#!/bin/bash

aws redshift restore-table-from-cluster-snapshot --cluster-identifier testrs1 --snapshot-identifier test3 --source-database-name testrs --source-schema-name public --source-table-name llisting --target-database-name testrs --target-schema-name public --new-table-name llisting

