#!/bin/bash
#-----------------------------------------------------------------#
echo "Start node log contains all actions"
grep "pid=6156" /rdsdbdata/data/log/start_node.log | tail -50

echo "Add context to see queries with newlines"
grep -C5 "pid=6156" /rdsdbdata/data/log/start_node.log | tail -50

echo "Alert log (user errors)"
/rdsdbdata/data/trace/alert_messages.log

echo "Diff conf with default"
diff $PADB_CONF /rdsdbdata/config/padb.conf
#-----------------------------------------------------------------#

