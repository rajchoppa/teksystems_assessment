#!/bin/bash

#set -x
echo "$0: monitoring $HOSTNAME health... "
ADMIN_EMAIL_GROUP="admin@xyz.com"

mail()
{
    user=$1
    subj=$2
    body=$3
    `echo $body | mail -s $subj $user`
    if [[ $? -ne 0 ]]; then
	echo "Unable to send the mail."
    fi
}

check_memory()
{
    FREE_OUTPUT=(`free | grep "Mem" | tr -s ' '`)
    MEM_USED=(`echo $FREE_OUTPUT | cut -f3 -d' '`)
    MEM_AVAILABLE=(`echo $FREE_OUTPUT | cut -f2 -d' '`)
    let MEM_USAGE=$MEM_USED/$MEM_AVAILABLE
    echo "Memory usage is: " $MEM_USAGE
    if [[ $MEM_USAGE -gt 90 ]]; then
	mail $ADMIN_EMAIL_GROUP, "Host: $HOSTNAME is consuming a lot of memory", "looking into ways of reducing the load !!"
    fi
}

check_cpu()
{
    CPU_USAGE=`ps -A -o pcpu | tail -n+2 | paste -sd+ | bc `
    echo "CPU Usage is $CPU_USAGE"
    if [[ $CPU_USAGE -gt 80 ]]; then
	echo "CPU Usage is heavy !!"
	mail $ADMIN_EMAIL_GROUP, "Host: $HOSTNAME is consuming a lot of memory", "looking into ways of reducing the load !!"
    fi
}

check_network()
{
    IFCFG_OUTPUT=`ifconfig -s | tr -s ' ' | cut -f1,5,9 -d' '`
    IFCFG_NOHEADER=`echo $IFCFG_OUTPUT | cut -f4- -d' '`
    #output of above will be: eth0 0 0 lo 0 0
    # interfacename recv_errors send_errors interface_name recv_errors...
    IFNAME=""
    for t in $IFCFG_NOHEADER; do
	count=0
	if [[ $(($count % 3)) -eq 0 ]]; then
	    IFNAME=$t
	else
	    if [[ $t -ne 0 ]]; then
		echo "send/receive errors on interface: " $IFNAME
		mail $ADMIN_EMAIL_GROUP, "Host:$HOSTNAME has network errors", "Network issues on interface: $IFNAME on host: $HOSTNAME"
	    fi
	fi
    done
}

check_memory
check_cpu
check_network
