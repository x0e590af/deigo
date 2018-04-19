# deigo useage

### cat /etc/hosts

    127.0.0.1       host1
    127.0.0.1       host2
 
### download 
        
    wget https://github.com/x0e590af/deigo/releases/latest
    tar zxvf xxxx.tar.gz
    cd  deigo-0.x.x

### config 
    cat etc/sys.config
    
    [
      { deigo, [
        {listen_port,"9528"},
        {hosts, ['node1@host1','node2@host2']}
      ]}
    
    ].
    
    cat etc/vm.args
    
    -sname node1@host1 
    -setcookie  cookiedeigo

 
    
### run                 
    ./bin/deigo start
    
    
### client install db

	➜  test redis-cli -p 9528
	
	127.0.0.1:9528> INITDB
    OK
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
	
### SET GET KEYS
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
	
	
### HSET HMGET HDEL

    127.0.0.1:9528> INITDB
    OK
    127.0.0.1:9528> HSET hhset hk4 hv4
    (integer) 1
    127.0.0.1:9528> HSET hhset hk3 hv3
    (integer) 1
    127.0.0.1:9528> HSET hhset hk2 hv2
    (integer) 1
    127.0.0.1:9528> HSET hhset hk1 hv1
    (integer) 1
    127.0.0.1:9528> HMGET hhset
    1) "hk1"
    2) "hv1"
    3) "hk2"
    4) "hv2"
    5) "hk3"
    6) "hv3"
    7) "hk4"
    8) "hv4"
    127.0.0.1:9528> HDEL hhset hk1
    (integer) 1
    127.0.0.1:9528> HMGET hhset
    1) "hk2"
    2) "hv2"
    3) "hk3"
    4) "hv3"
    5) "hk4"
    6) "hv4"

	
###  BACKUP 
	
	➜  test redis-cli -p 9528
    127.0.0.1:9528> INITDB
    OK
    127.0.0.1:9528> SET key1 value1
    OK
    127.0.0.1:9528> KEYS *
    1) "key1"
    127.0.0.1:9528> BACKUP "/data/backup.log"
    
### RESTORE  
 
    ➜  test redis-cli -p 9528
    127.0.0.1:9528> INITDB
    OK
    127.0.0.1:9528> RESTORE "/data/backup.log"
    OK
    127.0.0.1:9528> KEYS *
    1) "key1"
    2) "key3"     