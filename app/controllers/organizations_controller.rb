class OrganizationsController < ApplicationController
    include ApplicationHelper
    include BabelfishHelper

    before_action -> { doorkeeper_authorize! :admin }, only: :create
    before_action -> { doorkeeper_authorize! :write, :admin }, only: [:update, :deactivate]
    before_action -> { doorkeeper_authorize! :read, :write, :admin }, only: :read

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
        @dk = Doorkeeper::Application.new(
            name: org_name, 
            organization_id: org_id, 
            scopes: "read write", 
            redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
        @dk.save
        data = {"name": "admin", "organization-id": org_id, "oauth": {"client-id": @dk.uid.to_s, "client-secret": @dk.secret.to_s}}
        meta = {
            "type": "user"
        }
        dri = Oydid.hash(Oydid.canonical({"content": data, "meta": meta}))
        @store = Store.new(item: data.to_json, meta: meta.to_json, dri: dri)
        @store.save

        retVal = {"organization-id": org_id, "name": org_name, "admin-user-id": @store.id}
        render json: retVal,
               status: 200
    end

    def read
        id = params[:id]

puts "doorkeeper_org: " + doorkeeper_org.to_s + " (" + id.to_s + ")"
puts "doorkeeper_scope: " + doorkeeper_scope.to_s

        if doorkeeper_org != id.to_s && doorkeeper_scope != "admin"
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end
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

    end

    def deactivate

    end
end
