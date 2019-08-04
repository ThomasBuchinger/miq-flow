# frozen_string_literal: true

def domain_list_data
  domains = [
    { href: "#{miq_url}/automate/1", klass: 'MiqAeDomain', id: '1', name: 'ManageIQ', updated_on: Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'), description: nil, priority: '1', enabled: true, tenant_id: '1' } # rubocop:disable Metrics/LineLength
  ]
  { name: 'automate', subcount: domains.length, resources: domains }
end

def ae_method_data
  aem = [
    { href: "#{miq_url}/automate/1", fqname: '/feat_f1_buc/ns1/ns2/class/meth1', klass: 'MiqAeMethod', id: '1', name: 'meth1', data: 'text', location: 'inline' } # rubocop:disable Metrics/LineLength
  ]
  { name: 'automate', subcount: aem.length, resources: aem }
end
