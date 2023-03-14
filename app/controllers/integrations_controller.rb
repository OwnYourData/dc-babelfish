class IntegrationsController < ApplicationController
    include ApplicationHelper
    include BabelfishHelper

    before_action -> { doorkeeper_authorize! :read, :write, :admin }

    def match_up
        render json: {"match": true},
               status: 200
    end

    def match_d2a
        render json: {"match": true},
               status: 200
    end

    def create_d2a
        render json: {"d2a": true},
               status: 200
    end

    def extract_up
        render json: {"up": true},
               status: 200
    end

end
