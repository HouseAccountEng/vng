module Vng
  # A mock version of HTTPRequest which returns pre-built responses.
  # @example List the species of all breeds.
  #   host = ''subdomain.vonigo.com'
  #   path = '/api/v1/resources/breeds/'
  #   body = {securityToken: security_token}
  #   response = Vng::Request.new(path: path, body: body).run
  #   response['Breeds'].map{|breed| breed['species']}
  # @api private
  class Request
    # Initializes an MockRequest object.
    # @param [Hash] options the options for the request.
    # @option options [String] :host The host of the request URI.
    # @option options [String] :path The path of the request URI.
    # @option options [Hash] :query ({}) The params to use as the query
    #   component of the request URI, for instance the Hash +{a: 1, b: 2}+
    #   corresponds to the query parameters +"a=1&b=2"+.
    # @option options [Hash] :body The body of the request.
    def initialize(options = {})
      @host = options[:host]
      @path = options[:path]
      @body = options[:body]
      @query = options.fetch :query, {}
    end

    ROUTE_ID = 1630
    @@logged_out = false

    # Sends the request and returns the body parsed from the JSON response.
    # @return [Hash] the body parsed from the JSON response.
    # @raise [Vng::ConnectionError] if the request fails.
    # @raise [Vng::Error] if parsed body includes errors.
    def run
      instrument do
        case @path
        when '/api/v1/security/session/'
          raise Error.new 'Same franchise ID supplied.'
        when '/api/v1/security/login/'
          if @host == 'invalid-host'
            raise ConnectionError.new 'Failed to open connection'
          else
            { "securityToken"=>"1234567" }
          end
        when '/api/v1/security/logout/'
          if @@logged_out
            raise Error.new 'Session expired. '
          else
            @@logged_out = true
            {}
          end
        when '/api/v1/resources/zips/'
          { "Zips"=>[{ "zip"=>"21765", "zoneName"=>"Brentwood", "state"=>"MD" }] }
        when '/api/v1/resources/franchises/'
          if @body.key?(:objectID)
            { "Franchise"=>{ "objectID"=>"2201007" }, "Fields"=>[
              { "fieldID"=>9, "fieldValue"=>"vng@example.com" },
            ] }
          else
            { "Franchises"=>[
              { "franchiseID"=>106, "franchiseName"=>"Mississauga", "gmtOffsetFranchise"=>-300, "isActive"=>false },
              { "franchiseID"=>107, "franchiseName"=>"Boise", "gmtOffsetFranchise"=>-420, "isActive"=>true },
            ] }
          end
        when '/api/v1/resources/availability/'
          if @body.key?(:zip)
            { "Ids"=>{ "franchiseID"=>"172" } }
          elsif @body[:method] == '2'
            { "Ids"=>{ "lockID"=>"1406328" } }
          else
            { "Availability"=> [
              { "dayID"=>"20281119", "routeID"=>"#{ROUTE_ID}", "startTime"=>"1080" },
              { "dayID"=>"20281119", "routeID"=>"#{ROUTE_ID}", "startTime"=>"1110" },
            ] }
          end
        when '/api/v1/resources/breeds/'
          { "Breeds"=>[{ "breedID"=>2, "breed"=>"Bulldog", "species"=>"Dog", "optionID"=>303, "breedLowWeight"=>30, "breedHighWeight"=>50 }] }
        when '/api/v1/data/Leads/'
          { "Client"=>{ "objectID"=>"916347" }, "Fields"=> [
            { "fieldID"=>126, "fieldValue"=>"Vng Example" },
            { "fieldID"=>238, "fieldValue"=>"vng@example.com" },
            { "fieldID"=>1024, "fieldValue"=>"8648648640" },
          ] }
        when '/api/v1/data/Contacts/'
          { "Contact"=>{ "objectID"=>"2201007" }, "Fields"=>[
            { "fieldID"=>127, "fieldValue"=>"Vng" },
            { "fieldID"=>128, "fieldValue"=>"Example" },
            { "fieldID"=>97, "fieldValue"=>"vng@example.com" },
            { "fieldID"=>96, "fieldValue"=>"8648648640" },
          ] }
        when '/api/v1/data/Locations/'
          { "Location"=>{ "objectID"=>"995681" } }
        when '/api/v1/data/Assets/'
          if @body[:method].eql? '3'
            { "Asset"=>{ "objectID"=>"2201008" } }
          elsif @body[:method].eql? '4'
            {}
          end
        when '/api/v1/data/priceLists/'
          { "PriceItems"=>[
            { "priceItemID"=>275111, "priceItem"=>"15 Step SPA Grooming", "value"=>85.0, "taxID"=>256, "durationPerUnit"=>45.0, "serviceBadge"=>"Required", "serviceCategory"=>"15 Step Spa", "isOnline"=>true, "isActive"=>true },
            { "priceItemID"=>275300, "priceItem"=>"De-Matting - Light", "value"=>10.0, "taxID"=>256, "durationPerUnit"=>15.0, "serviceBadge"=>nil, "serviceCategory"=>"De-Shed", "isOnline"=>true, "isActive"=>true },
            { "priceItemID"=>275301, "priceItem"=>"De-Shedding Treatment", "value"=>20.0, "taxID"=>256, "durationPerUnit"=>15.0, "serviceBadge"=>nil, "serviceCategory"=>"De-Shed", "isOnline"=>true, "isActive"=>false },
          ] }
        when '/api/v1/resources/serviceTypes/'
          if @body.key?(:zip)
            {"ServiceTypes" => [
              {"serviceTypeID" => 14, "serviceType" => "Pet Grooming (name)", "duration" => 45,"isActive" => true},
              {"serviceTypeID" => 16, "serviceType" => "Pet Grooming (name)", "duration" => 45,"isActive" => false},
            ]}
          else
            { "ServiceTypes"=>[
              { "serviceTypeID"=>14, "serviceType"=>"Pet Grooming", "duration"=>90, "isActive"=>true },
            ] }
          end
        when '/api/v1/resources/Routes/'
          {"Routes" => [
            {"routeID" => ROUTE_ID, "routeName" => "Route 1", "isActive" => true},
            {"routeID" => 2, "routeName" => "Inactive", "isActive" => false},
          ]}
        when '/api/v1/data/WorkOrders/'
          { "WorkOrder"=>{ "objectID"=>"4138030" } }
        when '/api/v1/data/Cases/'
          if @body[:method].eql? '3'
            {"Case" => {"objectID" => "28503"}}
          elsif @body[:method].eql? '4'
            {}
          end
        end
      end
    end


    # Provides instrumentation to ActiveSupport listeners
    def instrument(&block)
      data = {}
      if defined?(ActiveSupport::Notifications)
        ActiveSupport::Notifications.instrument 'Vng.request', data, &block
      else
        block.call(data)
      end
    end
  end
end