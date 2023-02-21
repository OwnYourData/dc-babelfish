class UsersController < ApplicationController
    include ApplicationHelper
    include BabelfishHelper

    before_action -> { doorkeeper_authorize! :write, :admin }, only: [:create, :update, :delete]
    before_action -> { doorkeeper_authorize! :read, :write, :admin }, only: [:read, :wallet]

    def create
        data = params.except(:controller, :action, :user)
        meta = {
            "type": "user"
        }
        org_id = data["organization-id"]

        if doorkeeper_org != org_id.to_s && doorkeeper_scope != "admin"
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end
        if data["name"].to_s == ""
            render json: {"error": "invalid 'name'"},
                   status: 400
            return
        end

        dri = Oydid.hash(Oydid.canonical({"content": data, "meta": meta}))
        @store = Store.find_by_dri(dri)
        if @store.nil?
            if org_id.to_s == ""
                render json: {"error": "missing 'organization-id'"},
                       status: 400
                return
            end
            @org = Store.find(org_id) rescue nil
            if @org.nil?
                render json: {"error": "invalid 'organization-id'"},
                       status: 400
                return
            end
            @store = Store.new(item: data.to_json, meta: meta.to_json, dri: dri)
            @store.save
        end

        # create entry in Doorkeeper::Application
        @org = Store.find(org_id)
        @dk = Doorkeeper::Application.where(name: data["name"].to_s, organization_id: org_id).first rescue nil
        if @dk.nil?
            @dk = Doorkeeper::Application.new(
                name: data["name"].to_s, 
                organization_id: org_id, 
                scopes: "read write", 
                redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
            @dk.save
        end

        if !@dk.nil? && @dk.uid.to_s != ""
            retVal = {"user-id": @store.id, "name": data["name"].to_s, "organization-id": org_id, "oauth": {"client-id": @dk.uid.to_s, "client-secret": @dk.secret.to_s}}
            render json: retVal,
                   status: 200
        else
            render json: {"error": "cannot create user'"},
                   status: 500
        end

    end

    def update
        retVal = {"user-id": 1, "name": "John Doe"}
        render json: retVal,
               status: 200

    end

    def read
        id = params[:id]
        show_meta = params[:show_meta]
        @store = Store.find(id)
        if @store.nil?
            render json: {"error": "not found"},
                   status: 404
        else
            data = @store.item
            meta = @store.meta
            if !(data.is_a?(Hash) || data.is_a?(Array))
                data = JSON.parse(data) rescue nil
            end
            if !(meta.is_a?(Hash) || meta.is_a?(Array))
                meta = JSON.parse(meta) rescue nil
            end
            if meta["type"] != "user"
                render json: {"error": "not found"},
                       status: 404
            else
                org_id = data["organization-id"]
                if doorkeeper_org != org_id.to_s && doorkeeper_scope != "admin"
                    render json: {"error": "Not authorized"},
                           status: 401
                    return
                end

                if show_meta.to_s == "TRUE"
                    retVal = meta.merge({"dri" => @store.dri})
                else
                    retVal = data
                end
                render json: retVal.merge({"user-id" => @store.id}),
                       status: 200
            end
        end
    end

    def wallet
        retVal = {
          "user-id": 1,
          "dlt": [
            {
              "type": "Convex",
              "network": "testnet",
              "address": 48,
              "public-key": "0x82AbBf6EBb20cB21dB02375270b9C2078c2e09e9D7C492be6439c61F23917022",
              "balance": 96816794
            }
          ]
        }
        render json: retVal,
               status: 200

    end
end
