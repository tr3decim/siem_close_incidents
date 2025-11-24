#!/bin/bash

curdate=`date +%Y-%m-%dT00:00:00.000Z`
#curdate="2025-11-19T00:00:00.000Z"

token=$1
corname=$2
action=$3
message=$4

if [[ $1 == "" || $2 == "" || $3 == "" || $4 == "" ]]; then
    echo -e "Usage:\n  $0 \"param1\" \"param2\""
    echo -e "	'param1' is an api token"
    echo -e "	'param2' is a correlation name of the incident"
    echo -e "	'param3' is an action - Closed, Approved, InProgress or Resolved"
    echo -e "	'param4' is a comment"
    exit
elif [[ "$1" =~ " " || "$2" =~ " " ]]; then
    echo "No space available in 'param1', 'param2' or 'param3'"
    exit
elif [[ "$3" != "Closed" || "$3" != "Approved" || "$3" != "InProgress" || "$3" != "Resolved" ]]; then
    echo "Incorrect action"
    exit
fi

json_data=$(jq -n \
--arg curdate "$curdate" \
--arg corname "$corname" \
'{
    "offset": 0,
    "limit": 999,
    "timeFrom": $curdate,
    "filterTimeType": "creation",
    "filter": {
	"select": ["key","name","category","type","status","created","assigned"],
	"where": "CorrelationNames = '$corname' and status = new"
    }
}')

echo "Getting IDs of incidents from SIEM"
ids=`curl -skX POST \
    -d "$json_data" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" https://mskpsiem01.coresvc.tech/api/v2/incidents | jq -r '.incidents.[].id'`

echo "Found $(echo "$ids" | wc -l) incident(s)"

json_data_put=$(jq -n \
'
{
    "id": "Closed",
    "measures": "",
    "message": "False positive"
}
')

for id in $ids; do
    inc=`curl -skX GET -H "Authorization: Bearer $token" \
              -H "Content-Type: application/json" \
               https://mskpsiem01.coresvc.tech/api/incidentsReadModel/incidents/$id`

    key=`jq -r '.key' <<<"$inc"`
    name=`jq -r '.name' <<<"$inc"`
    src=`jq -r '.source' <<<"$inc"`
    detected=`jq -r '.detected' <<<"$inc"`
    type=`jq -r '.type' <<<"$inc"`
    severity=`jq -r '.severity' <<<"$inc"`
    targets=`jq -c '{groups: [.targets.groups[].id],assets: [.targets.assets[].id],networks: [.targets.networks[].id],addresses: [.targets.addresses[].id],others: [.targets.others[].name]}' <<<"$inc"`
    attackers=`jq -c '{groups: [.attackers.groups[].id],assets: [.attackers.assets[].id],networks: [.attackers.networks[].id],addresses: [.attackers.addresses[].id],others: [.attackers.others[].name]}' <<<"$inc"`
    desc=`jq -r '.description' <<<"$inc"`
    grps=`jq -c '[.groups[].id]' <<<"$inc"`
    inf=`jq -r '.influence' <<<"$inc"`
    params=`jq -r '.parameters[]' <<<"$inc"`

    jd=$(jq -n \
	--arg name "$name" \
	--arg src "$src" \
	--arg detected "$detected" \
	--arg type "$type" \
	--arg severity "$severity" \
	--argjson targets "$targets" \
	--argjson attackers "$attackers" \
	--arg desc "$desc" \
	--argjson grps "$grps" \
	--arg inf "$inf" \
	--arg params "$params" \
    '{
	"assigned": "107dd2cd-4ac2-4af5-8c3e-9feec2fcd74c",
        "attackers": $attackers,
	"description": $desc,
        "detected": $detected,
	"groups": $grps,
	"influence": $inf,
        "name": $name,
	"parameters": $params,
        "severity": $severity,
        "source": $src,
        "targets": $targets,
        "type": $type
    }')

    echo "Closing $key - https://mskpsiem01.coresvc.tech/#/incident/incidents/view/$id"
    curl -skX PUT -H "Authorization: Bearer $token" \
             -H "Content-Type: application/json" \
	     -d "$jd" \
              https://mskpsiem01.coresvc.tech/api/incidents/$id

    curl -skX PUT -H "Authorization: Bearer $token" \
             -H "Content-Type: application/json" \
	     -d "$json_data_put" \
              https://mskpsiem01.coresvc.tech/api/incidents/$id/transitions

done

