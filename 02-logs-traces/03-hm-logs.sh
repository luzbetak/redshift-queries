#!/bin/bash
#------------------------------------------------------------------------#
cd /rdsdbdata/data/log
protocol.log 				#-- logs all restarts
start_node.log 				#-- logs all transactions/queries/connections
grep "2018-01-04 18" /rdsdbdata/data/log/start_node.log | tail -100
#------------------------------------------------------------------------#
