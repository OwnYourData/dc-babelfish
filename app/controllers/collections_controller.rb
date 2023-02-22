class CollectionsController < ApplicationController
    include ApplicationHelper
    include BabelfishHelper

    before_action -> { doorkeeper_authorize! :write, :admin }, only: [:create, :update, :delete]
    before_action -> { doorkeeper_authorize! :read, :write, :admin }, only: [:read, :list]

    def create
        data = params.except(:controller, :action, :collection)
        if !data["_json"].nil?
            data = data["_json"]
        end
        meta = {
            "type": "collection",
            "organization-id": doorkeeper_org
        }
        dri = Oydid.hash(Oydid.canonical({"content": data, "meta": meta}))
        @store = Store.find_by_dri(dri)
        if @store.nil?
            @store = Store.new(item: data.to_json, meta: meta.to_json, dri: dri)
            @store.save
        end

        retVal = {"collection-id": @store.id, "name": data["name"].to_s}
        render json: retVal,
               status: 200
    end

    def update
        # input
        id = params[:id]
        data = params.permit!.except(:controller, :action, :collection, :id).transform_keys(&:to_s)
        if !data["_json"].nil?
            data = data["_json"]
        end

        # validate
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
        if !data["meta"].nil?
            meta = meta.merge(data["meta"])
            data = data.except("meta")
        end        
        if meta["type"] != "collection"
            render json: {"error": "not found"},
                   status: 404
            return
        end
        if meta["organization-id"] != doorkeeper_org
            render json: {"error": "Not authorized"},
                   status: 401
            return
        end

        dri = Oydid.hash(Oydid.canonical({"content": data, "meta": meta}))
        if Store.find_by_dri(dri).nil?
            # update data
            @store.item = data.to_json
            @store.meta = meta.to_json
            @store.dri = dri
            if @store.save
                render json: {"collection-id": @store.id},
                       status: 200
            else
                render json: {"error": "cannot save update"},
                       status: 400
            end
        else
            render json: {"error": "cannot save update"},
                   status: 404
        end
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
                data_json = JSON.parse(data) rescue nil
                if data_json.nil?
                    data = JSON.parse(data.to_json) rescue nil
                else
                    data = data_json
                end
            end
            if !(meta.is_a?(Hash) || meta.is_a?(Array))
                meta = JSON.parse(meta) rescue nil
            end
            if meta["type"] != "collection"
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
            if retVal.is_a?(Array)
                retVal={"collection": retVal}
            end
            render json: retVal.merge({"collection-id" => @store.id}),
                   status: 200
        end
    end

    def list
        retVal=[
          {"collection-id": 1, "name": "My Repository"},
          {"collection-id": 2, "name": "Repository 2"}
        ]
        render json: retVal,
               status: 200

    end

    def delete
        retVal={
          "collection-id": 1,
          "name": "My Repository"
        }
        render json: retVal,
               status: 200

    end
end
