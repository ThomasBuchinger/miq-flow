# frozen_string_literal: true

module MiqFlow
  module MiqProvider
    # This provider assumes to be running on a ManageIQ Appliance
    class Appliance
      attr_accessor :container_name

      def initialize(opts = {}) end

      def import(tmpdir, fs_domain, miq_domain)
        commands = [
          'rake -f /var/www/miq/vmdb/Rakefile evm:automate:import'\
          " DOMAIN=#{fs_domain} IMPORT_AS=#{miq_domain} IMPORT_DIR=#{tmpdir} OVERWRITE=true PREVIEW=false ENABLED=true"
        ]
        $logger.info('Importing with Appliance provider')
        success = commands.all? do |cmd|
          system(cmd)
        end
        raise MiqFlow::ProviderError, 'Failed to Import to Appliance' unless success
      end
    end
  end
end
