#!/bin/bash

#set -x

echo $0 "would have to be run using sudo privilages"
echo "######## Installing Elastic Search..."

IS_AUTORESTART=0
TEST_INSTALL=0
while getopts ":at" opt; do
    case $opt in
	a)
	   echo "-a autoadd was invoked, will be added to autorestart procedure"
	   IS_AUTORESTART=1
	   ;;
	t)
	   echo "-t test option is invoked, Will run few test cases"
	   TEST_INSTALL=1
	   ;;
	\?)
	    echo "Invalid option: -$OPTARG"
	    exit 1
	   ;;
    esac
done

javaMajorVersion=`java -version 2>&1 | grep version | cut -f2 -d'"' | cut -f1 -d'-'`

if [[ $javaMajorVersion = "" || $javaMajorVersion -lt 8 ]]; then
    echo "Please insttall the latest java version"
    exit 1
fi

DEB_FILE=elasticsearch-5.0.0.deb
URL=https://artifacts.elastic.co/downloads/elasticsearch
TMP_DIR=/tmp

#get the file from internet to local filesystem
wget $URL/$DEB_FILE -O $TMP_DIR/$DEB_FILE

if [[ $? -ne 0 ]]; then
    echo "Unable to fetch the package"
    exit 1
fi

#install it
dpkg -i /tmp/elasticsearch-5.0.0.deb

if [[ $IS_AUTORESTART -eq 1 ]]; then
    systemctl enable elasticsearch.service
fi

if [[ $TEST_INSTALL -eq 1 ]]; then
    systemctl start elasticsearch
    OUTPUT=`curl -X GET 'http://localhost:9200'`
    if [[ `echo $OUTPUT | grep "name" | wc -l` -eq 0 ]]; then
	echo "elasticsearch is not up, test failed"
        exit 1
    fi
    if [[ `echo $OUTPUT | grep "cluster_name" | wc -l` -eq 0 ]]; then
	echo "elasticsearch is not up, test failed"
        exit 1
    fi
    echo "elasticsearch test case has succeeded. !!"
fi

echo "######### elasticsearch installation is complete !!!"


