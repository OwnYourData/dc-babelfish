Rails.application.routes.draw do
    use_doorkeeper
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
    namespace :api, defaults: { format: :json } do
        scope "(:version)", :version => /v1/, module: :v1 do
            match 'active',             to: 'resources#active',       via: 'get'
            match 'data',               to: 'stores#read',            via: 'get'
            match 'data',               to: 'stores#write',           via: 'post'

        end
        # template for multiple versions
        # scope "v1", module: :v1 do
        #     match 'active',             to: 'resources#active',       via: 'get'
        # end
        # scope "(:version)", :version => /v2/, module: :v2 do    # default version
        #     match 'active',             to: 'resources#active2',       via: 'get'
        # end
    end

    # Babelfish ===================
    # Service handling
    match 'list',             to: 'services#page',   via: 'get'
    match 'list/count/page',  to: 'services#page',   via: 'get'
    match 'service/search',   to: 'services#search', via: 'get'
    match 'service/:id',      to: 'services#read',   via: 'get'
    match 'service/:id/meta', to: 'services#read',   via: 'get', defaults: { show_meta: "TRUE"}
    match 'service',          to: 'services#create', via: 'post'
    match 'service/:id',      to: 'services#update', via: 'put'
    match 'service/:id',      to: 'services#delete', via: 'delete'

    # Organisation handling
    match 'organization/:id',      to: 'organizations#read',   via: 'get'
    match 'organization/:id/meta', to: 'organizations#read',   via: 'get', defaults: { show_meta: "TRUE"}
    match 'organization/:id/list', to: 'organizations#list',   via: 'get'
    match 'organization',          to: 'organizations#create', via: 'post'
    match 'organization/:id',      to: 'organizations#update', via: 'put'
    match 'organization/:id',      to: 'organizations#delete', via: 'delete'

    # User hanlding
    match 'user/:id',        to: 'users#read',   via: 'get'
    match 'user/:id/meta',   to: 'users#read',   via: 'get', defaults: { show_meta: "TRUE"}
    match 'user/:id/wallet', to: 'users#wallet', via: 'get'
    match 'user',            to: 'users#create', via: 'post'
    match 'user/:id',        to: 'users#update', via: 'put'
    match 'user/:id',        to: 'users#delete', via: 'delete'

    # Collection handling
    match 'collection/list',        to: 'collections#list',    via: 'get'
    match 'collection/:id',         to: 'collections#read',    via: 'get'
    match 'collection/:id/meta',    to: 'collections#read',    via: 'get', defaults: { show_meta: "TRUE"}
    match 'collection/:id/objects', to: 'collections#objects', via: 'get'
    match 'collection',             to: 'collections#create',  via: 'post'
    match 'collection/:id',         to: 'collections#update',  via: 'put'
    match 'collection/:id',         to: 'collections#delete',  via: 'delete'

    # Object handling
    match 'object/:id',                 to: 'objects#read',   via: 'get'
    match 'object/:id/meta',            to: 'objects#read',   via: 'get', defaults: { show_meta: "TRUE"}
    match 'object/:id/write',           to: 'objects#write',  via: 'put'
    match 'object/:id/read',            to: 'objects#object', via: 'get'
    match 'object/:object_id/:user_id', to: 'objects#access', via: 'get'
    match 'object',                     to: 'objects#create', via: 'post'
    match 'object/:id',                 to: 'objects#update', via: 'put'
    match 'object/:id',                 to: 'objects#delete', via: 'delete'

    # DID handling ================
    # OYDID resolving
    match 'doc/:did',             to: 'dids#show',              via: 'get', constraints: {did: /.*/}
    match 'doc_raw/:did',         to: 'dids#raw',               via: 'get', constraints: {did: /.*/}
    match 'did/:did',             to: 'dids#show',              via: 'get', constraints: {did: /.*/}
    match 'did',                  to: 'dids#create',            via: 'post'
    match 'doc',                  to: 'dids#create',            via: 'post'
    match 'log/:id',              to: 'logs#show',              via: 'get', constraints: {id: /.*/}
    match 'log/:did',             to: 'logs#create',            via: 'post', constraints: {did: /.*/}
    match 'doc/:did',             to: 'dids#delete',            via: 'delete', constraints: {did: /.*/}

    # VC & VP endpoints
    match 'credentials/:id',      to: 'credentials#show_vc',    via: 'get', constraints: {id: /.*/}
    match 'credentials',          to: 'credentials#publish_vc', via: 'post'
    match 'presentations/:id',    to: 'credentials#show_vp',    via: 'get', constraints: {id: /.*/}
    match 'presentations',        to: 'credentials#publish_vp', via: 'post'

    # Uniresolver endpoint
    match '1.0/identifiers/:did', to: 'dids#resolve',           via: 'get', constraints: {did: /.*/}

    # Uniregistrar endpoints
    match '1.0/create',     to: 'dids#uniregistrar_create',     via: 'post'
    match '1.0/update',     to: 'dids#uniregistrar_update',     via: 'post'
    match '1.0/deactivate', to: 'dids#uniregistrar_deactivate', via: 'post'

    # OYDID Auth challenge
    match 'oydid/init',     to: 'dids#init',                    via: 'post'
    match 'oydid/token',    to: 'dids#token',                   via: 'post'

    # Administrative ================
    match '/version',   to: 'application#version', via: 'get'
    match ':not_found', to: 'application#missing', via: [:get, :post], :constraints => { :not_found => /.*/ }

end
