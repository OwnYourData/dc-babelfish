class OrganizationsController < ApplicationController
    include ApplicationHelper
    include BabelfishHelper

    before_action -> { doorkeeper_authorize! :admin }, only: :create
    before_action -> { doorkeeper_authorize! :write, :admin }, only: [:update, :delete]
    before_action -> { doorkeeper_authorize! :read, :write, :admin }, only: [:read, :list]

    def create
        data = params.except(:controller, :action, :organization)
        if !data["_json"].nil?
            data = data["_json"]
        end
        meta = {
            "type": "organization"
        }
        dri = Oydid.hash(Oydid.canonical({"content": data, "meta": meta}))
        @store = Store.find_by_dri(dri)
        if @store.nil?
            @store = Store.new(item: data.to_json, meta: meta.to_json, dri: dri)
            @store.save
        end
        org_id = @store.id
        org_name = data["name"].to_s

        # create admin user for organization
        @dk = Doorkeeper::Application.where(name: "admin", organization_id: org_id).first rescue nil
        if @dk.nil?
            @dk = Doorkeeper::Application.new(
                name: "admin", 
                organization_id: org_id, 
                scopes: "read write", 
                redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
            @dk.save
        end
        data = {"name": "admin", "organization-id": org_id}
        meta = {
            "type": "user"
        }
        dri = Oydid.hash(Oydid.canonical({"content": data, "meta": meta}))
        @store = Store.find_by_dri(dri)
        if @store.nil?
            @store = Store.new(item: data.to_json, meta: meta.to_json, dri: dri, key: "user_" + org_id.to_s)
            @store.save
        end

        retVal = {"organization-id": org_id, "name": org_name, "admin-user-id": @store.id}
        render json: retVal,
               status: 200
    end

    def read
        id = params[:id]
        if doorkeeper_org != id.to_s && doorkeeper_scope != "admin"
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end
        show_meta = params[:show_meta]
        @store = Store.find(id) rescue nil
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
            if meta["type"] != "organization"
                render json: {"error": "not found"},
                       status: 404
            else
                if show_meta.to_s == "TRUE"
                    retVal = meta.merge({"dri" => @store.dri})
                else
                    retVal = data
                end
                render json: retVal.merge({"organization-id" => @store.id}),
                       status: 200
            end
        end
    end

    def update
        retVal = {"organization-id": 1, "name": "ACME Inc."}
        render json: retVal,
               status: 200

    end

    def delete
        retVal = {"organization-id": 1, "name": "ACME Inc."}
        render json: retVal,
               status: 200

    end

    def list
        id = params[:id]
        if doorkeeper_org != id.to_s && doorkeeper_scope != "admin"
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end
        @store = Store.find(id) rescue nil
        if @store.nil?
            render json: {"error": "not found"},
                   status: 404
            return
        end
        meta = @store.meta
        if !(meta.is_a?(Hash) || meta.is_a?(Array))
            meta = JSON.parse(meta) rescue nil
        end
        if meta["type"] != "organization"
            render json: {"error": "not found"},
                   status: 404
            return
        end

        @orgs = Store.where(key: "user_" + id.to_s)
        retVal = []
        @orgs.each do |org|
            data = org.item
            if !(data.is_a?(Hash) || data.is_a?(Array))
                data = JSON.parse(data) rescue {}
            end
            retVal << {"user-id": org.id, "name": data["name"].to_s}
        end unless @orgs.nil?
        render json: retVal,
               status: 200

    end
end
