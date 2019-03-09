# frozen_string_literal: true

module MiqFlow
  # Implements API calls to ManageIQ
  class ManageIQ
    include ApiMethods

    attr_reader :url, :user
    def initialize(url: nil, user: nil, password: nil)
      @url      = url      || $settings[:miq][:url]
      @user     = user     || $settings[:miq][:user]
      @password = password || $settings[:miq][:password]
    end

    def list_domains
      columns = %w[name id description priority enabled updated_on]
      data = query_automate_model('', attributes: columns, type: :domain, depth: 1)
      data.each{ |d| $logger.debug("Found Domain: #{d['name']}") }
      text = data.map do |d|
        desc   = d['description'].to_s.empty? ? '' : " (#{d['description']})"
        update = MiqFlow.human_readable_time(timestamp: Time.parse(d['updated_on']))
        ena    = d['enabled'] ? 'yes' : 'no'
        "#{d['name']}#{desc}: ID=#{d['id']} Enabled=#{ena} Prio=#{d['priority']} Last Update=#{update}"
      end.join("\n")
      text
    end

    def find_ae_methods(domain, columns: [])
      columns = %i[name data location] if columns.empty?
      api_data = query_automate_model(domain, type: :method, attributes: columns)
      api_data.map do |d|
        parts = d['fqname'].split('/')
        re = {
          fqname: d['fqname'],
          domain: parts[1],
          namespace: parts[2..-3].join('/'),
          class: parts[-2]
        }
        columns.each{ |col| re[col.to_sym] = d[col.to_s] }
        re
      end
    end
  end
end
