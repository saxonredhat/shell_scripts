#!/bin/bash
/usr/local/mysql/bin/mysqldump -uroot -pxxxxxxx --opt -R --databases lbd payment_gateway ftc >/data/backup/mysql/lbd_payment_gateway_ftc_`date +%Y%m%d_%H%M%S`.sql
