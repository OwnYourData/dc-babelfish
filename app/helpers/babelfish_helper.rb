module BabelfishHelper
    def doorkeeper_org
        return Doorkeeper::Application.find(doorkeeper_token.application_id).organization_id.to_s
    end

    def doorkeeper_scope
       return doorkeeper_token.scopes.to_s
    end
end
