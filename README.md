deigo
=====

    deigo db 

Build
-----

    $ sh compile_release.sh


client
-----
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