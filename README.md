# arti in Docker

With snowflake, obfs4proxy and webtunnel.

## Use

### docker run

```sh
docker run -it --rm -p 127.0.0.1:9150:9150 severecloud/arti:latest
```

with config

```sh
docker run -it --rm \
  -v ./arti.toml:/home/arti/.config/arti/arti.toml:ro \
  -p 127.0.0.1:9150:9150 \
  severecloud/arti:latest
```

### docker-compose.yml

```yml
services:
  arti:
    container_name: arti
    image: severecloud/arti:latest
    port:
      - "127.0.0.1:9150:9150"
    # volumes:
    #   - ./arti.toml:/home/arti/.config/arti/arti.toml:ro
```

```sh
docker compose up
```

### Check

```sh
curl -s --socks5-hostname 127.0.0.1:9150 'https://check.torproject.org/' | grep -m1 Congratulations
```

Output: _Congratulations. This browser is configured to use Tor._

## Config

`/home/arti/.config/arti/arti.toml`

### Use bridges

#### obfs4proxy

```toml
[bridges]
enabled = true

# For example:
bridges = '''
192.0.2.83:80 $0bac39417268b96b9f514ef763fa6fba1a788956
[2001:db8::3150]:8080 $0bac39417268b96b9f514e7f63fa6fb1aa788957
obfs4 bridge.example.net:80 $0bac39417268b69b9f514e7f63fa6fba1a788958 ed25519:dGhpcyBpcyBbpmNyZWRpYmx5IHNpbGx5ISEhISEhISA iat-mode=1
'''

[[bridges.transports]]
protocols = ["obfs4"]
path = "/usr/bin/obfs4proxy"
#arguments = ["-enableLogging", "-logLevel", "DEBUG"]
arguments = []
run_on_startup = false
```

#### snowflake

```toml
[bridges]
enabled = true

# For example:
bridges = '''
snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://snowflake-broker.torproject.net.global.prod.fastly.net/ fronts=foursquare.com,github.githubassets.com ice=stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn
'''

[[bridges.transports]]
protocols = ["snowflake"]
path = "/usr/bin/snowflake-client"
#arguments = ["-log-to-state-dir", "-log", "snowflake.log"]
arguments = []
run_on_startup = false
```

#### webtunnel

```toml
[bridges]
enabled = true

# For example:
bridges = '''
webtunnel 192.0.2.3:1 url=https://akbwadp9lc5fyyz0cj4d76z643pxgbfh6oyc-167-71-71-157.sslip.io/5m9yq0j4ghkz0fz7qmuw58cvbjon0ebnrsp0
'''

[[bridges.transports]]
protocols = ["webtunnel"]
path = "/usr/bin/webtunnel-client"
arguments = []
run_on_startup = false
```
