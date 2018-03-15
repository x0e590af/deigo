# deigo useage

### cat /etc/hosts

    127.0.0.1       host1
    127.0.0.1       host2
 
### download
        
    https://github.com/x0e590af/deigo
    download  deigo-0.1.2.tar.gz
    tar zxvf 0.1.2.tar.gz
### dep

    cp deigo-0.1.2 /data/work/deigo_node_1
    cp deigo-0.1.2 /data/work/deigo_node_2

    
### node1  config       

    cd /data/work/deigo_node_1
    
    vim start.sh
    
    #!/bin/bash
    
    export RELX_REPLACE_OS_VARS=true
    
    export NODE_NAME=node1@host1
    export COOKIE_NAME=cookiedeigo
    export PORT=9527
    export DBDIR=/tmp/deigo1/
    export DBLOGFILE=/tmp/deigo1.sasl_log
    
    ./bin/deigo console
    
### node2  config       

    cd /data/work/deigo_node_2
    
    vim start.sh
    
    #!/bin/bash
    
    export RELX_REPLACE_OS_VARS=true
    
    export NODE_NAME=node2@host2
    export COOKIE_NAME=cookiedeigo
    export PORT=9528
    export DBDIR=/tmp/deigo2/
    export DBLOGFILE=/tmp/deigo2.sasl_log
    
    ./bin/deigo console
        
### run 
         
    sh start.sh
    
    
### client

	➜  test redis-cli -p 9528
	127.0.0.1:9528> KEYS *
	(nil)
	127.0.0.1:9528> SET key1 value1
	OK
	127.0.0.1:9528> GET key1
	"value1"
	127.0.0.1:9528> SET key2 value2
	OK
	127.0.0.1:9528> GET key2
	"value2"
	127.0.0.1:9528> KEYS *
	1) "key1"
	2) "key2"
	127.0.0.1:9528> SET key2 value2
	OK
	127.0.0.1:9528> KEYS *
	1) "key1"
	2) "key2"
	127.0.0.1:9528> FLUSHDB
	OK
	127.0.0.1:9528> KEYS *
	(nil)
	127.0.0.1:9528>