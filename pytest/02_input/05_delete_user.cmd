curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $MASTER_TOKEN" -X DELETE $GW_HOST/user/`echo "{\"name\":\"Delete User\", \"organization-id\": $ORG_ID, \"now\":\"$(date)\"}" | envsubst | curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $USER_TOKEN" -d @- -X POST $GW_HOST/user/ | jq -r '."user-id"'` | jq -r '.name'