module GitFlow
  module MiqProvider
    # This provider assumes to be running on a ManageIQ Appliance
    class Appliance

      attr_accessor :container_name

      def initialize(opts={})
        
      end

      def import(tmpdir, fs_domain, miq_domain)
        commands =  [
          "rake -f /var/www/miq/vmdb/Rakefile evm:automate:import DOMAIN=#{fs_domain} IMPORT_AS=#{miq_domain} IMPORT_DIR=#{tmpdir}/automate OVERWRITE=true PREVIEW=false ENABLED=true"
        ]
        $logger.debug('Importing with Appliance provider')
        commands.each do |cmd|
          system(cmd)
        end
      end

    end
  end
end
