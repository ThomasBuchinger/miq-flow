# frozen_string_literal: true

require 'rest-client'
require 'json'

module MiqFlow
  # ManageIQ API related stuff
  module ApiMethods
    def query_automate_model(path, type: :undefined, attributes: nil, depth: -1)
      klass_type = get_api_type(type)
      raise MiqFlow::ApiError, "Unknown Type: #{type}, while quering automate model" if klass_type.nil?

      path = path.start_with?('/') ? path[1..-1] : path
      response = invoke_miq_api("/automate/#{path}?depth=#{depth}#{get_attributes_param(attributes)}")
      select_for_type(response, type)
    end

    def select_for_type(model, type)
      api_type = get_api_type(type)
      return model['resources'] if api_type == 'undef'

      model['resources'].select{ |dom| dom['klass'] == api_type }
    end

    def get_api_type(type)
      api_type_mapping = {
        undefined: 'undef',
        domain: 'MiqAeDomain',
        namespace: 'MiqAeNamespace',
        class: 'MiqAeClass',
        instance: 'MiqAeInstance',
        method: 'MiqAeMethod'
      }.freeze
      api_type_mapping[type.to_sym]
    end

    def get_attributes_param(attributes)
      attributes = attributes.kind_of?(Array) ? attributes + ['klass'] : [attributes, 'klass'].compact()
      attributes.empty? ? '' : "&attributes=#{attributes.join(',')}"
    end

    def invoke_miq_api(path)
      req_opts = { method: :get, user: @user, password: @password, verify_ssl: false }
      req_opts[:url] = @url + path
      $logger.debug("Invoke API: #{req_opts[:url]}")

      response = RestClient::Request.execute(req_opts)
      JSON.parse(response.body)
    rescue RestClient::Exceptions::Timeout => e
      raise MiqFlow::ConnectionError, "Unable to connect to ManageIQ: #{e.message}", []
    rescue RestClient::Exception => e
      raise MiqFlow::BadResponseError, "Invalid API call: #{e.message}", []
    rescue Errno::ECONNREFUSED => e
      raise MiqFlow::ConnectionError, "ManageIQ API unavailalbe: #{e.message}", []
    rescue SocketError => e
      raise MiqFlow::ConnectionError, "Unable to connect ot ManageIQ: #{e.message}", []
    end

    def miq_action_api(action_id, path, method: :post, resource: {})
      req_opts = { method: method, user: @user, password: @password, verify_ssl: false }
      req_opts[:url] = @url + path
      req_opts[:payload] = JSON.generate(action: action_id, resource: resource)

      $logger.debug("API #{method} Action: #{req_opts[:url]}")
      $logger.debug("  Payload: #{req_opts[:payload]}") unless resource.empty?

      response = RestClient::Request.execute(req_opts)
      JSON.parse(response.body)
    rescue RestClient::Exceptions::Timeout => e
      raise MiqFlow::ConnectionError, "Unable to connect to ManageIQ: #{e.message}", []
    rescue RestClient::Exception => e
      raise MiqFlow::BadResponseError, "Invalid API call: #{e.message}", []
    rescue Errno::ECONNREFUSED => e
      raise MiqFlow::ConnectionError, "ManageIQ API unavailalbe: #{e.message}", []
    rescue SocketError => e
      raise MiqFlow::ConnectionError, "Unable to connect ot ManageIQ: #{e.message}", []
    end
  end
end
