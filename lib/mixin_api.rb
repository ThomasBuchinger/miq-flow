require 'rest-client'
require 'json'
module GitFlow
  # ManageIQ API related stuff
  module ApiMethods
    def query_automate_model(path, type: :undefined, attributes: nil, depth: -1)
      klass_type = get_api_type(type)
      raise GitFlow::Error, "Unknown Type: #{type}, while quering automate model" if klass_type.nil?

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
      url = 'https://localhost:8443/api'
      req_opts = { method: :get, user: 'admin', password: 'smartvm', verify_ssl: false }
      req_opts[:url] = url + path
      $logger.debug("Invoke API: #{req_opts[:url]}")

      response = RestClient::Request.execute(req_opts)
      JSON.parse(response.body)
    end
  end
end
