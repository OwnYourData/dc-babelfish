class ServicesController < ApplicationController
    include ApplicationHelper

    def page
        retVal = [
            {"service-id": 1, "name": "DID Lint"},
            {"service-id": 2, "name": "xyz"}
        ]
        render json: retVal,
               status: 200

    end

    def read
        retVal = {
          "service-id": 1,
          "interface": {
            "info": { "title": "DID Lint" },
            "servers": [{"url": "https://didlint.ownyourdata.eu"}],
            "party": "data_consumer",
            "paths": {
              "/api/validate": {
                "post": {
                  "requestBody": {
                    "content": {
                      "application/json": {
                        "schema": {} 
                      }
                    }
                  }
                }
              }
            }
          },
          "data": nil,
          "governance": {
            "dpv:hasProcessing": ["dpv:Use"],
            "dpv:hasPurpose": "dpv:Purpose",
            "dpv:hasExpiryTime": "6 months"
          }
        }
        render json: retVal,
               status: 200

    end

end
