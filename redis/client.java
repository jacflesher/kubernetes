@Slf4j
@Service
public class RedisClient {


    @Value("${spring.data.redis.password}")
    String password;

    @Value("${spring.data.redis.host}")
    String host;

    @Value("${spring.data.redis.port}")
    int port;

    @Value("${spring.profiles.active}")
    String profiles;

    private JedisPool jedisPool;

    @PostConstruct
    public void init() {
        if (host != null && !host.isEmpty() && port > 0) {
            log.info("Initializing JedisPool with host: {} and port: {}", host, port);
            jedisPool = new JedisPool(new JedisPoolConfig(), host, port, 2000, password, true);
        } else {
            log.error("Invalid Redis host or port: {}:{}", host, port);
        }
    }


    public String redisAdd(String property, String val) {
        try (Jedis jedis = this.jedisConnect()){
            this.jedisAuth(jedis);
            jedis.set(property, val);
            String value = jedis.get(property);
            return value.equals(val)
                    ? "Success :: Property '" + property + "' with value '" + value + "' added to Redis Cache"
                    : "Failed :: Could not add property '" + property + "' with value '" + value + "' to Redis Cache";
        } catch (Exception ex) {
            ex.printStackTrace();
            return "ConnectToRedis.redisAdd :: Failed due to exception :: " + ex.getMessage();
        }
    }

    public String redisGet(String property) {
        try (Jedis jedis = this.jedisConnect()){
            this.jedisAuth(jedis);
            String value = jedis.get(property);
            return Objects.requireNonNullElseGet(value, () -> "Failed :: Property '" + property + "' not found");
        } catch (Exception ex) {
            ex.printStackTrace();
            return "ConnectToRedis.redisGet :: Failed due to exception :: " + ex.getMessage();
        }
    }

    public boolean redisKeyExists(String property) {
        try (Jedis jedis = this.jedisConnect()){
            this.jedisAuth(jedis);
            return jedis.get(property) != null;
        }
    }

    public void redisAddWithExpiration(String key, long seconds, String value) {
        try (Jedis jedis = this.jedisConnect()){
            this.jedisAuth(jedis);
            jedis.setex(key, seconds, value);
            String val = jedis.get(key);
            String logstatus = value.equals(val)
                    ? "Success :: Property '" + key + "' with value '" + value + "' added to Redis Cache"
                    : "Failed :: Could not add key '" + key + "' with value '" + value + "' to Redis Cache";
            log.info(logstatus);
        }
    }

    public List<String> redisGetAll() {
        List<String> redisItemList = new ArrayList<>();
        Jedis jedis = this.jedisConnect();
        try {
            this.jedisAuth(jedis);
            long totalKeyCount = jedis.dbSize();
            String cursor = ScanParams.SCAN_POINTER_START;
            ScanParams scanParams = new ScanParams().count((int) totalKeyCount).match("*");
            do {
                ScanResult<String> scanResult = jedis.scan(cursor, scanParams);
                redisItemList.addAll(scanResult.getResult()); // process the keys
                cursor = scanResult.getCursor();
            } while (!cursor.equals(ScanParams.SCAN_POINTER_START));
            return redisItemList;
        } finally {
            jedis.close();
        }
    }

    public void redisGetIncidentStream(Consumer<String> itemProcessor) {
        Jedis jedis = this.jedisConnect();
        try {
            this.jedisAuth(jedis);
            long keyCount = jedis.dbSize();
            String cursor = ScanParams.SCAN_POINTER_START;
            ScanParams scanParams = new ScanParams().count((int) keyCount).match("*");
            do {
                ScanResult<String> scanResult = jedis.scan(cursor, scanParams);
//                scanResult.getResult().forEach(itemProcessor);
                scanResult.getResult()
                        .stream()
                        .filter(item -> item.matches(INCIDENT_PATTERN))
                        .forEach(itemProcessor);

                cursor = scanResult.getCursor();
            } while (!cursor.equals(ScanParams.SCAN_POINTER_START));
        } catch (JedisConnectionException e) {
            e.printStackTrace();
        } finally {
            jedis.close();
        }
    }

    public void redisGetRequestTaskStream(Consumer<String> itemProcessor) {
        Jedis jedis = this.jedisConnect();
        try {
            this.jedisAuth(jedis);
            long keyCount = jedis.dbSize();
            String cursor = ScanParams.SCAN_POINTER_START;
            ScanParams scanParams = new ScanParams().count((int) keyCount).match("*");
            do {
                ScanResult<String> scanResult = jedis.scan(cursor, scanParams);
                scanResult.getResult()
                        .stream()
                        .filter(item -> item.matches(REQUESTTASK_PATTERN))
                        .forEach(itemProcessor);

                cursor = scanResult.getCursor();
            } while (!cursor.equals(ScanParams.SCAN_POINTER_START));
        } catch (JedisConnectionException e) {
            e.printStackTrace();
        } finally {
            jedis.close();
        }
    }


    public String redisDelete(String property) {
        try (Jedis jedis = this.jedisConnect()){
            this.jedisAuth(jedis);
            if (jedis.get(property) != null) {
                jedis.del(property);
                return jedis.get(property) == null
                        ? "Success :: Property '" + property + "' deleted from Redis cache."
                        : "Failed :: Could not delete " + property + " from Redis cache!!";
            } else {
                return "Failed :: Property '" + property + "' not found";
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            return "ConnectToRedis.redisDelete :: Failed due to exception :: " + ex.getMessage();
        }
    }


    private void jedisAuth(Jedis jedis){
        if (!profiles.toLowerCase().contains("local")){
            jedis.auth(password);
        }
    }

    private Jedis jedisConnect() {
        if (profiles.contains("local")){
            return new Jedis(host, port);
        }
        if (jedisPool == null){
            throw new IllegalStateException("JedisPool not initialized properly.");
        }
        return jedisPool.getResource();
    }

}
