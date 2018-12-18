module GitFlow
  # Implements API calls to ManageIQ
  class ManageIQ
    include ApiMethods

    def list_domains
      columns = %w[name id description priority enabled updated_on]
      data = query_automate_model('', attributes: columns, type: :domain, depth: 1)
      data.each{ |d| $logger.debug("Found Domain: #{d['name']}") }
      text = data.map do |d|
        desc   = d['description'].empty? ? '' : " (#{d['description']})"
        update = GitFlow.human_readable_time(timestamp: Time.parse(d['updated_on']))
        ena    = d['enabled'] ? 'yes' : 'no'
        "#{d['name']}#{desc}: ID=#{d['id']} Enabled=#{ena} Prio=#{d['priority']} Last Update=#{update}"
      end.join("\n")
      text
    end
  end
end
