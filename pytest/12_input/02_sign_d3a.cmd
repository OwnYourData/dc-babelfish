oydid vc-proof --issuer did:oyd:zQmZzphAYNtaatPHTSFM9TQgxGkUbdLuFNAcsWLYif2WSdH%40babelfish.data-container.net --doc-pwd shop-pwd | curl -H "Content-Type: application/json" -d @- -X POST $MK_HOST/api/data