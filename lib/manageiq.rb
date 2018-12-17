module GitFlow
  class ManageIQ
    include ApiMethods

    def list_domains
      data = query_automate_model('', attributes: %w[name id description priority enabled updated_on], type: :domain, depth: 1)
      data.each{|d| $logger.debug("Found Domain: #{d['name']}") }
      text = data.map do |d|
        desc   = d['description'].empty? ? '' : " (#{d['description']})"
        update = GitFlow.human_readable_time(timestamp: Time.parse(d['updated_on']))
        "#{d['name']}#{desc}: ID=#{d['id']} Enabled=#{d['enabled'] ? 'yes' : 'no'} Prio=#{d['priority']} Last Update=#{update}"
      end.join("\n")
      text
    end    
  end
end
