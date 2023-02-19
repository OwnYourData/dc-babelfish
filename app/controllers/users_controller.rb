class UsersController < ApplicationController
    include ApplicationHelper

    def create
        data = params.except(:controller, :action, :user)
        meta = {
            "type": "user"
        }
        dri = Oydid.hash(Oydid.canonical({"content": data, "meta": meta}))
        @store = Store.find_by_dri(dri)
        if @store.nil?
            org_id = data["organization-id"]
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

        retVal = {"user-id": @store.id, "name": data["name"].to_s, "organization-id": org_id}
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
end
