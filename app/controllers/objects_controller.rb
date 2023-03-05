class ObjectsController < ApplicationController
    include ApplicationHelper
    include BabelfishHelper

    before_action -> { doorkeeper_authorize! :write, :admin }, only: [:create, :write, :update, :delete]
    before_action -> { doorkeeper_authorize! :read, :write, :admin }, only: [:read, :object, :access]

    def create
        data = params.permit!.except(:controller, :action, :object).transform_keys(&:to_s)
        if !data["_json"].nil?
            data = data["_json"]
        end
        meta = {
            "type": "object",
            "organization-id": doorkeeper_org
        }
        if !data["meta"].nil?
            meta = meta.merge(data["meta"])
            data = data.except("meta")
        end
        dri = Oydid.hash(Oydid.canonical({"content": data, "meta": meta}))
        col_id = data["collection-id"] rescue ""
        if col_id.to_s == ""
            render json: {"error": "missing 'collection-id'"},
                   status: 400
            return
        end
        @col = Store.find(col_id) rescue nil
        if @col.nil?
            render json: {"error": "invalid 'collection-id'"},
                   status: 400
            return
        end
        col_meta = @col.meta
        if !(col_meta.is_a?(Hash) || col_meta.is_a?(Array))
            col_meta = JSON.parse(col_meta) rescue nil
        end
        if col_meta["type"] != "collection"
            render json: {"error": "invalid 'collection-id'"},
                   status: 400
            return
        end
        if col_meta["organization-id"] != doorkeeper_org
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end

        @store = Store.find_by_dri(dri)
        if @store.nil?
            @store = Store.new(item: data.to_json, meta: meta.to_json, dri: dri, key: "object_" + col_id.to_s)
            @store.save
        end

        render json: {"object-id": @store.id, "collection-id": col_id},
               status: 200
    end

    def update
        # input
        id = params[:id]
        data = params.permit!.except(:controller, :action, :object, :id).transform_keys(&:to_s)
        if !data["_json"].nil?
            data = data["_json"]
        end

        # checks
        @store = Store.find(id)
        if @store.nil?
            render json: {"error": "not found"},
                   status: 404
            return
        end
        meta = @store.meta
        if !(meta.is_a?(Hash) || meta.is_a?(Array))
            meta = JSON.parse(meta) rescue nil
        end
        meta = meta.transform_keys(&:to_s)
        if meta["type"] != "object"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["delete"].to_s.downcase == "true"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["organization-id"] != doorkeeper_org
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end
        if !data["meta"].nil?
            meta = {
                "type": "object"
            }
            meta = meta.merge(data["meta"])
            data = data.except("meta")
        end
        meta = meta.transform_keys(&:to_s)
        if !(data.is_a?(Hash) || data.is_a?(Array))
            json_data = JSON.parse(data) rescue nil
            if json_data.nil?
                data = JSON.parse(data.to_json) rescue nil
            else
                data = json_data
            end
        end
        col_id = data["collection-id"] rescue ""
        if col_id.to_s == ""
            render json: {"error": "missing 'collection-id'"},
                   status: 400
            return
        end
        @col = Store.find(col_id) rescue nil
        if @col.nil?
            render json: {"error": "invalid 'collection-id'"},
                   status: 400
            return
        end
        col_meta = @col.meta
        if !(col_meta.is_a?(Hash) || col_meta.is_a?(Array))
            col_meta = JSON.parse(col_meta) rescue nil
        end
        if col_meta["type"] != "collection"
            render json: {"error": "invalid 'collection-id'"},
                   status: 400
            return
        end
        if col_meta["organization-id"] != doorkeeper_org
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end
        dri = Oydid.hash(Oydid.canonical({"content": data, "meta": meta}))
        if !Store.find_by_dri(dri).nil?
            render json: {"error": "object already exists"},
                   status: 400
            return
        end

        # update data
        @store.item = data.to_json
        @store.meta = meta.to_json
        @store.dri = dri
        if @store.save
            render json: {"object-id": @store.id, "collection-id": col_id},
                   status: 200
        else
            render json: {"error": "cannot save update"},
                   status: 400
        end

    end

    def write
        # input
        id = params[:id]
        payload = params.except(:controller, :action, :object, :id)
        if !payload["_json"].nil?
            payload = payload["_json"]
        end
        payload_dri = Oydid.hash(Oydid.canonical(payload.to_json))
        @store = Store.find(id)
        if @store.nil?
            render json: {"error": "not found"},
                   status: 404
            return
        end

        # validate
        data = @store.item
        meta = @store.meta
        if !(data.is_a?(Hash) || data.is_a?(Array))
            data = JSON.parse(data) rescue nil
        end
        if !(meta.is_a?(Hash) || meta.is_a?(Array))
            meta = JSON.parse(meta) rescue nil
        end
        if meta["type"] != "object"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["delete"].to_s.downcase == "true"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["organization-id"] != doorkeeper_org
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end
        col_id = data["collection-id"]

        # store payload
        pl_meta = {"type": "payload"}
        if data["payload"].to_s == ""
            @pl = Store.new(item: payload.to_json, meta: pl_meta.to_json, dri: payload_dri)
        else
            @pl = Store.find_by_dri(payload_dri)
            if @pl.nil?
                @pl = Store.new(item: payload.to_json, meta: pl_meta.to_json, dri: payload_dri)
            else
                @pl.item = payload.to_json
                @pl.meta = pl_meta.to_json
                @pl.dri = payload_dri
            end
        end
        if @pl.save
            data["payload"] = payload_dri
            @store.item = data.to_json
            if @store.save
                retVal = {"object-id": @store.id, "collection-id": col_id}
                render json: retVal,
                       status: 200
            else
                render json: {"error": @store.errors, "object": @store.id.to_s},
                       status: 400
            end
        else
            render json: {"error": @store.errors},
                   status: 400
        end
    end

    def read
        id = params[:id]
        show_meta = params[:show_meta]
        @store = Store.find(id)
        if @store.nil?
            render json: {"error": "not found"},
                   status: 404
            return
        end
        data = @store.item
        meta = @store.meta
        if !(data.is_a?(Hash) || data.is_a?(Array))
            data_json = JSON.parse(data) rescue nil
            if data_json.nil?
                data = JSON.parse(data.to_json) rescue nil
            else
                data = data_json
            end
        end
        if !(meta.is_a?(Hash) || meta.is_a?(Array))
            meta_json = JSON.parse(meta) rescue nil
            if meta_json.nil?
                meta = JSON.parse(meta.to_json) rescue nil
            else
                meta = meta_json
            end
        end
        if meta["type"] != "object"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["delete"].to_s.downcase == "true"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["organization-id"] != doorkeeper_org
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end
        if show_meta.to_s == "TRUE"
            retVal = meta.merge({"dri" => @store.dri})
        else
            retVal = data
        end
        render json: retVal.merge({"object-id" => @store.id}),
               status: 200
    end

    def access
        object_id = params[:object_id]
        user_id = params[:user_id]
        @obj = Store.find(object_id)
        @user = Store.find(user_id)
        if @obj.nil?
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if @user.nil?
            render json: {"error": "not found"},
                   status: 404
            return
        end
        obj_data = @obj.item
        obj_meta = @obj.meta
        if !(obj_data.is_a?(Hash) || obj_data.is_a?(Array))
            obj_data = JSON.parse(obj_data) rescue nil
        end
        if !(obj_meta.is_a?(Hash) || obj_meta.is_a?(Array))
            obj_meta = JSON.parse(obj_meta) rescue nil
        end
        if obj_meta["type"] != "object"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if obj_meta["delete"].to_s.downcase == "true"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        user_data = @obj.item
        user_meta = @obj.meta
        if !(user_data.is_a?(Hash) || user_data.is_a?(Array))
            user_data = JSON.parse(user_data) rescue nil
        end
        if !(user_meta.is_a?(Hash) || user_meta.is_a?(Array))
            user_meta = JSON.parse(user_meta) rescue nil
        end
        if user_meta["type"] != "user"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if user_meta["delete"].to_s.downcase == "true"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        retVal = {
          "object-id": object_id,
          "collection-id": user_id,
          "name": obj_data["name"].to_s,
          "access": true
        }
        status_code = 200
        if user_meta["organization-id"] != doorkeeper_org
            retVal = {
              "object-id": object_id,
              "collection-id": user_id,
              "access": false
            }
            status_code = 401
        end
        if obj_meta["organization-id"] != doorkeeper_org
            retVal = {
              "object-id": object_id,
              "collection-id": user_id,
              "access": false
            }
            status_code = 401
        end
        render json: retVal,
               status: status_code

    end

    def object
        id = params[:id]
        @store = Store.find(id)
        if @store.nil?
            render json: {"error": "not found"},
                   status: 404
            return
        end
        data = @store.item
        meta = @store.meta
        if !(data.is_a?(Hash) || data.is_a?(Array))
            data = JSON.parse(data) rescue nil
        end
        if !(meta.is_a?(Hash) || meta.is_a?(Array))
            meta = JSON.parse(meta) rescue nil
        end
        if meta["type"] != "object"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["delete"].to_s.downcase == "true"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["organization-id"] != doorkeeper_org
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end
        payload_dri = data["payload"].to_s
        if payload_dri == ""
            render json: {"error": "no payload attached to object"},
                   status: 400
            return
        end
        @pl = Store.find_by_dri(payload_dri)
        if @pl.nil?
            render json: {"error": "no payload attached to object"},
                   status: 404
            return
        end
        payload = @pl.item
        if !(payload.is_a?(Hash) || payload.is_a?(Array))
            payload = JSON.parse(payload) rescue nil
        end
        render json: payload,
               status: 200
    end

    def delete
        # input
        id = params[:id]

        # validate
        @store = Store.find(id)
        if @store.nil?
            render json: {"error": "not found"},
                   status: 404
            return
        end
        data = @store.item
        meta = @store.meta
        if !(data.is_a?(Hash) || data.is_a?(Array))
            data = JSON.parse(data) rescue nil
        end
        if !(meta.is_a?(Hash) || meta.is_a?(Array))
            meta = JSON.parse(meta) rescue nil
        end
        meta = meta.transform_keys(&:to_s)
        if meta["type"] != "object"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["delete"].to_s.downcase == "true"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["organization-id"].to_s != doorkeeper_org && doorkeeper_scope != "admin"
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end

        meta = meta.merge("delete": true)
        col_id = data["collection-id"]
        @store.meta = meta.to_json
        @store.dri = nil
        col_id = 
        if @store.save
            render json: {"object-id": @store.id, "collection-id": col_id},
                   status: 200
        else
            render json: {"error": "cannot delete"},
                   status: 400
        end

    end
end
