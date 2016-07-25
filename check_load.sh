#!/bin/bash
echo "############################"  >>/data/deploy/scripts/check_load.log
date >>/data/deploy/scripts/check_load.log
echo "############################"  >>/data/deploy/scripts/check_load.log
echo "==>占用内存最多的10个进程:" >>/data/deploy/scripts/check_load.log
ps -aux | sort -k4nr | head -n 10 >>/data/deploy/scripts/check_load.log
echo "" >>/data/deploy/scripts/check_load.log
echo "==>占用CPU最多的10个进程:" >>/data/deploy/scripts/check_load.log
ps -aux | sort -k3nr | head -n 10 >>/data/deploy/scripts/check_load.log
echo "" >>/data/deploy/scripts/check_load.log

