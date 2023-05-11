module StorageHelper
    def getStorage_by_id(id)
        @store = Store.find(id) rescue nil
        if @store.nil?
            return nil
        else
            id = @store.id.to_s
            if !(@store.item.is_a?(Hash) || @store.item.is_a?(Array))
                data = JSON.parse(@store.item) rescue nil
            else
                data = @store.item
            end
            if !(@store.meta.is_a?(Hash) || @store.meta.is_a?(Array))
                meta = JSON.parse(@store.meta) rescue nil
            else
                meta = @store.meta
            end
            return {"id": id, "data": data, "meta": meta, "created-at": @store.created_at, "updated-at": @store.updated_at}
        end
    end

    def getStorage_by_dri(dri)
        @store = Store.find_by_dri(dri) rescue nil
        if @store.nil?
            return nil
        else
            id = @store.id.to_s
            if !(@store.item.is_a?(Hash) || @store.item.is_a?(Array))
                data = JSON.parse(@store.item) rescue nil
            else
                data = @store.item
            end
            if !(@store.meta.is_a?(Hash) || @store.meta.is_a?(Array))
                meta = JSON.parse(@store.meta) rescue nil
            else
                meta = @store.meta
            end
            return {"id": id, "data": data, "meta": meta, "created-at": @store.created_at, "updated-at": @store.updated_at}
        end
    end

    def newStorage(col_id, data, meta, dri, key)
        @store = Store.new(item: data, meta: meta, dri: dri, key: key)
        if @store.save
            return {"id": @store.id.to_s}
        else
            return {"error": @store.errors, "id": nil}
        end
    end

    def updateStorage(col_id, id, data, meta, dri, key)
        @store = Store.find(id)
        @store.item = data
        @store.meta = meta
        @store.dri = dri
        @store.key = key
        if @store.save
            return {"id": @store.id.to_s}
        else
            return {"error": @store.errors, "id": nil}
        end


    end
end
