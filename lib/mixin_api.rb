require 'rest-client'
require 'json'
module GitFlow
  # ManageIQ API related stuff
  module ApiMethods
    def self.list_domains
      $logger.info('List Domains with API provider')
      puts query_automate_model('ManageIQ/System/Request', attributes: %w[name klass], type: :method)
    end

    def self.query_automate_model(path, type: :undefined, attributes: nil, depth: -1)
      depth      = 0 if type == :domain
      klass_type = get_api_type(type)
      raise GitFlow::Error, "Unknown Type: #{type}, while quering automate model" if klass_type.nil?

      response = invoke_miq_api("/automate/#{path}?depth=#{depth}#{get_attributes_param(attributes)}")
      select_for_type(response, type)
    end

    def self.select_for_type(model, type)
      api_type = get_api_type(type)
      return model['resources'] if api_type == 'undef'

      model['resources'].select{ |dom| dom['klass'] == api_type }
    end

    def self.get_api_type(type)
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

    def self.get_attributes_param(attributes)
      attributes = attributes.kind_of?(Array) ? attributes : [attributes].compact()
      attributes.empty? ? '' : "&attributes=#{attributes.join(',')}"
    end

    def self.invoke_miq_api(path)
      url = 'https://localhost:8443/api'
      req_opts = { method: :get, user: 'admin', password: 'smartvm', verify_ssl: false }
      req_opts[:url] = url + path
      $logger.debug("Invoke API: #{req_opts[:url]}")

      response = RestClient::Request.execute(req_opts)
      JSON.parse(response.body)
    end
  end
end
