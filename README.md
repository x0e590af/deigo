# deigo useage

### cat /etc/hosts

    127.0.0.1       host1
    127.0.0.1       host2
 
### download 
        
    wget https://github.com/x0e590af/deigo/releases/download/0.1.5/deigo-0.1.5.tar.gz
    tar zxvf 0.1.5.tar.gz
    cd  deigo-0.1.5

### config 
    cat conf/default.sh
    
    #!/usr/bin/env bash
 
    export RELX_REPLACE_OS_VARS=true
    export NODE_NAME=node1@host1
    export COOKIE_NAME=cookiedeigo
    export PORT=9528
    
### run                 
    sh ./bin/deigo_client.sh  start
    
    
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
	
### backup 
	
	➜  test redis-cli -p 9528
    127.0.0.1:9528> INITDB
    OK
    127.0.0.1:9528> INITTB
    OK
    127.0.0.1:9528> SET key1 value1
    OK
    127.0.0.1:9528> KEYS *
    1) "key1"
    127.0.0.1:9528> BACKUP "/data/backup.log"
    
### restore  
 
    ➜  test redis-cli -p 9528
    127.0.0.1:9528> INITDB
    OK
    127.0.0.1:9528> RESTORE "/data/backup.log"
    OK
    127.0.0.1:9528> KEYS *
    1) "key1"
    2) "key3"     