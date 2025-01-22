# redis-cli


### 1. **General Redis Commands**

- **`redis-cli -h <host> -p <port> -a <password>`*: Logs into the CLI
  ```bash
  redis-cli -h "127.0.0.1" -p "6379" -a "yourpassword"
  ```

- **`sudo /var/vcap/packages/redis/bin/redis-cli -h 127.0.0.1 -p 6379 -a "$(grep "requirepass" < /var/vcap/jobs/redis/config/redis.conf | awk -F' ' '{print $2}')"`*: Logs into the CLI in a Tanzu Redis Container
  ```bash
  sudo /var/vcap/packages/redis/bin/redis-cli -h 127.0.0.1 -p 6379 -a "$(grep "requirepass" < /var/vcap/jobs/redis/config/redis.conf | awk -F' ' '{print $2}')"
  ```

- Script to read redis instance storage usage
  ```bash
  #!/bin/bash
  
  # Run this script, or copy paste snippet below, inside redis service instance while sudo
  
  REDIS_PASS="xxxyyyzzz"
  USED_MEMORY=$(
      redis-cli -h 127.0.0.1 -p 6379 -a "$REDIS_PASS" --no-auth-warning INFO MEMORY | grep 'used_memory:' | awk -F':' '{print $2}' | tr -d '[:space:]'
  )
  MAX_MEMORY=$(
      redis-cli -h 127.0.0.1 -p 6379 -a "$REDIS_PASS"  --no-auth-warning INFO MEMORY | grep 'maxmemory:' | awk -F':' '{print $2}' | tr -d '[:space:]'
  )
  echo; echo; echo; echo; echo;
  echo "/////////////////////"
  echo "///  $(tput bold)$(( USED_MEMORY * 100 / MAX_MEMORY ))%$(tput sgr0) Usage ///////"
  echo "/////////////////////"
  ```
  
  - **``**: Sets the value of a key.
  ```bash
  SET mykey "hello"
  ```

- **`SET key value`**: Sets the value of a key.
  ```bash
  SET mykey "hello"
  ```

- **`GET key`**: Retrieves the value of a key.
  ```bash
  GET mykey
  ```

- **`DEL key`**: Deletes a key.
  ```bash
  DEL mykey
  ```

- **`EXISTS key`**: Checks if a key exists.
  ```bash
  EXISTS mykey
  ```

- **`KEYS pattern`**: Lists all keys matching the pattern (use cautiously in production environments).
  ```bash
  KEYS *
  KEYS user:*  # Matches all keys starting with "user:"
  ```

- **`TTL key`**: Returns the time to live (in seconds) of a key. Returns `-1` if the key does not have an expiration time.
  ```bash
  TTL mykey
  ```

- **`EXPIRE key seconds`**: Sets an expiration time (in seconds) for a key.
  ```bash
  EXPIRE mykey 60  # Expires in 60 seconds
  ```

- **`PERSIST key`**: Removes the expiration time from a key.
  ```bash
  PERSIST mykey
  ```

- **`FLUSHALL`**: Removes all keys from all databases.
  ```bash
  FLUSHALL
  ```

- **`FLUSHDB`**: Removes all keys from the currently selected database.
  ```bash
  FLUSHDB
  ```

### 2. **String Commands**

- **`INCR key`**: Increments the value of the key by 1. If the key does not exist, it is set to 1.
  ```bash
  INCR counter
  ```

- **`DECR key`**: Decrements the value of the key by 1.
  ```bash
  DECR counter
  ```

- **`MSET key1 value1 key2 value2 ...`**: Sets multiple keys to multiple values.
  ```bash
  MSET key1 "value1" key2 "value2"
  ```

- **`MGET key1 key2 ...`**: Retrieves the values of multiple keys.
  ```bash
  MGET key1 key2
  ```

- **`APPEND key value`**: Appends a value to the end of an existing key.
  ```bash
  APPEND mykey "world"
  ```

- **`STRLEN key`**: Returns the length of the value stored in the key.
  ```bash
  STRLEN mykey
  ```

### 3. **Hash Commands**

- **`HSET key field value`**: Sets the value of a field in a hash.
  ```bash
  HSET myhash field1 "value1"
  ```

- **`HGET key field`**: Retrieves the value of a field in a hash.
  ```bash
  HGET myhash field1
  ```

- **`HGETALL key`**: Retrieves all fields and values in a hash.
  ```bash
  HGETALL myhash
  ```

- **`HDEL key field`**: Deletes a field from a hash.
  ```bash
  HDEL myhash field1
  ```

- **`HINCRBY key field increment`**: Increments the value of a field in a hash by the given increment (can also be negative).
  ```bash
  HINCRBY myhash field1 10
  ```

- **`HKEYS key`**: Lists all the fields in a hash.
  ```bash
  HKEYS myhash
  ```

- **`HVALS key`**: Lists all the values in a hash.
  ```bash
  HVALS myhash
  ```

### 4. **List Commands**

- **`LPUSH key value`**: Pushes an element to the head (beginning) of a list.
  ```bash
  LPUSH mylist "first"
  ```

- **`RPUSH key value`**: Pushes an element to the tail (end) of a list.
  ```bash
  RPUSH mylist "second"
  ```

- **`LPOP key`**: Pops an element from the head of a list.
  ```bash
  LPOP mylist
  ```

- **`RPOP key`**: Pops an element from the tail of a list.
  ```bash
  RPOP mylist
  ```

- **`LRANGE key start stop`**: Retrieves elements from a list in the specified range.
  ```bash
  LRANGE mylist 0 -1  # Returns all elements in the list
  ```

- **`LLEN key`**: Returns the length of a list.
  ```bash
  LLEN mylist
  ```

- **`LINSERT key BEFORE|AFTER pivot value`**: Inserts a value in a list before or after a specified pivot.
  ```bash
  LINSERT mylist BEFORE "second" "new_value"
  ```

### 5. **Set Commands**

- **`SADD key member`**: Adds a member to a set.
  ```bash
  SADD myset "apple"
  ```

- **`SREM key member`**: Removes a member from a set.
  ```bash
  SREM myset "apple"
  ```

- **`SMEMBERS key`**: Returns all the members of a set.
  ```bash
  SMEMBERS myset
  ```

- **`SISMEMBER key member`**: Checks if a member exists in a set.
  ```bash
  SISMEMBER myset "apple"
  ```

- **`SCARD key`**: Returns the number of members in a set.
  ```bash
  SCARD myset
  ```

- **`SINTER key1 key2 ...`**: Returns the intersection of multiple sets.
  ```bash
  SINTER set1 set2
  ```

### 6. **Sorted Set Commands**

- **`ZADD key score member`**: Adds a member to a sorted set, or updates its score if it already exists.
  ```bash
  ZADD myzset 1 "one"
  ```

- **`ZREM key member`**: Removes a member from a sorted set.
  ```bash
  ZREM myzset "one"
  ```

- **`ZRANGE key start stop`**: Returns a range of members in a sorted set, by rank.
  ```bash
  ZRANGE myzset 0 -1  # Get all members
  ```

- **`ZREVRANGE key start stop`**: Returns a range of members in a sorted set, by rank, in reverse order.
  ```bash
  ZREVRANGE myzset 0 -1
  ```

- **`ZINCRBY key increment member`**: Increments the score of a member in a sorted set by a given value.
  ```bash
  ZINCRBY myzset 5 "one"
  ```

- **`ZCARD key`**: Returns the number of members in a sorted set.
  ```bash
  ZCARD myzset
  ```

### 7. **Pub/Sub Commands**

- **`PUBLISH channel message`**: Sends a message to a channel.
  ```bash
  PUBLISH mychannel "hello"
  ```

- **`SUBSCRIBE channel`**: Subscribes to a channel to receive messages.
  ```bash
  SUBSCRIBE mychannel
  ```

- **`UNSUBSCRIBE channel`**: Unsubscribes from a channel.
  ```bash
  UNSUBSCRIBE mychannel
  ```

### 8. **Transactions**

- **`MULTI`**: Starts a transaction.
  ```bash
  MULTI
  ```

- **`EXEC`**: Executes the transaction (all commands after `MULTI`).
  ```bash
  EXEC
  ```

- **`DISCARD`**: Discards the transaction.
  ```bash
  DISCARD
  ```

### 9. **Server Commands**

- **`INFO`**: Provides information and statistics about the Redis server.
  ```bash
  INFO
  ```

- **`MONITOR`**: Streams all Redis commands processed by the server in real-time.
  ```bash
  MONITOR
  ```

- **`CONFIG SET parameter value`**: Changes the configuration of the Redis server.
  ```bash
  CONFIG SET maxmemory 100mb
  ```

- **`SHUTDOWN`**: Shuts down the Redis server.
  ```bash
  SHUTDOWN
  ```
