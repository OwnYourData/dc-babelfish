class ObjectsController < ApplicationController
    include ApplicationHelper

    def create
        data = params.permit!.except(:controller, :action, :object).transform_keys(&:to_s)
        if !data["_json"].nil?
            data = data["_json"]
        end
        meta = {
            "type": "object"
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
        @store = Store.find_by_dri(dri)
        if @store.nil?
            @store = Store.new(item: data.to_json, meta: meta.to_json, dri: dri)
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
        if show_meta.to_s == "TRUE"
            retVal = meta.merge({"dri" => @store.dri})
        else
            retVal = data
        end
        render json: retVal.merge({"object-id" => @store.id}),
               status: 200
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
end
