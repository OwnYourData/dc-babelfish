curl -s -H "Authorization: Bearer `curl -s -d grant_type=client_credentials -d client_id=S0zmwl_s_GrnY2K88bLIyd5VDA3iKwFocm3BIYA0z-U -d client_secret=m0x6fmvtpv5Hyy_bG2OFKoEs_MxG9b5lYHsP0FxlcDE -d scope=read -X POST https://babelfish.data-container.net/oauth/token | jq -r '.access_token'`" $GW_HOST/collection/448/objects | jq '[type == "array" and length > 0] | any'