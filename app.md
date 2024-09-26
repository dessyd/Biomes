# Minecraft App for Splunk

## ta_mc

inputs.conf

```conf
[monitor:///data/logs/*.log]
disabled = 0
sourcetype = mc
```

## mc

index.conf

```conf
[mc]
coldPath = $SPLUNK_DB/mc/colddb
homePath = $SPLUNK_DB/mc/db
maxTotalDataSizeMB = 512000
frozenTimePeriodInSecs = 5184000
thawedPath = $SPLUNK_DB/mc/thaweddb
```

props.conf

```conf
[mc]
DATETIME_CONFIG = 
LINE_BREAKER = ([\r\n]+)
NO_BINARY_CHECK = true
SHOULD_LINEMERGE = false
category = Personnalisé
description = Minecraft Server logs
pulldown_type = 1
TRANSFORMS-set_index_mc = set_index_mc
EXTRACT-mc = ^\[\d+:\d+:\d+\] \[(?<mc_component>.+\/\w+)\]\: (?<mc_payload>.+)
REPORT-component = component
REPORT-player = player_action, player_has, player_uuid, player_entity
REPORT-world = world

FIELDALIAS-cim = mc_player AS user mc_severity_level AS vendor_severity
LOOKUP-cim_severity = cim_severity mc_severity_level OUTPUTNEW severity
```

transforms.conf

```conf
[set_index_mc]
REGEX = .
SOURCE_KEY = _raw
DEST_KEY = _MetaData:Index
FORMAT = mc

[component]
SOURCE_KEY = mc_component
REGEX = (\w+) (.+)\/(\w+)$
FORMAT = mc_process_name::$1 mc_process_details::$2 mc_severity_level::$3

[player_action]
SOURCE_KEY = mc_payload
REGEX = (\w+) (joined|left) the game
FORMAT = mc_player::$1 mc_action::$2

[player_has]
SOURCE_KEY = mc_payload
REGEX = (\w+) has (\w+) the (\w+) \[(.+)\]
FORMAT = mc_player::$1 mc_action::$2 mc_what::$3 mc_result::$4

[player_uuid]
SOURCE_KEY = mc_payload
REGEX = UUID of player (\w+) is (.+)
FORMAT = mc_player::$1 mc_uuid::$2

[player_entity]
SOURCE_KEY = mc_payload
REGEX = (\w+)\[\/(.+):(\d+)\] (\w+) (\w+ ){4}(\d+) at \(\[(\w+)\](.+),(.+),(.+)\)
FORMAT = mc_player::$1 src::$2 mc_port::$3 mc_action::$4 mc_entity_id::$6 mc_world::$7 x::$8 y::$9 z::$10

[world]
SOURCE_KEY = host 
REGEX = uf-mc-(\w+)
FORMAT = mc_world::$1

[cim_severity]
batch_index_query = 0
case_sensitive_match = 1
default_match = unknown
filename = cim_severity.csv
```

eventtypes.conf

```conf
[mc_logged]
search = sourcetype=mc mc_action=logged
# session

[mc_start]
search = sourcetype=mc mc_action=joined
# start
# session

[mc_stop]
search = sourcetype=mc mc_action=left
# stop
# session

[mc_authenticator]
search = sourcetype=mc mc_process_name=User
```

tags.conf

```conf
[eventtype=mc_logged]
session = enabled

[eventtype=mc_start]
session = enabled
start = enabled

[eventtype=mc_stop]
session = enabled
stop = enabled

[mc_severity_level=ERROR]
error = enabled

[eventtype=mc_authenticator]
authentication = enabled
default = enabled
```

lookups/cim_severity.csv

```csv
mc_severity_level,severity
INFO,informational
WARN,medium
ERROR,high
```
