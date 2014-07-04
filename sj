#!/bin/sh

# File ID: 29dba898-4962-11df-adc3-d5e071bed206

free_space() {
    df --block-size=1M "$1" | commify | grep /dev/ | tr -s ' ' | cut -f 4 -d ' ' | tr -d '\n'
}

if test "$1" = "space"; then
    while :; do
        free_space .
        sleep 1
        echo -n '  '
    done
elif test "$1" = "date"; then
    ntpdate -q pool.ntp.org
elif test "$1" = "kern"; then
    tail -F /var/log/kern.log
else
    test -d /n900/. && sudo=sudo || unset sudo
    while :; do
        $sudo ping 178.79.142.16
        sleep 1
        echo ============================================
    done
fi
