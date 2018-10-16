module GitFlow
  module MiqProvider
    class Appliance

      attr_accessor :container_name

      def initialize(container_name: 'manageiq')
        @container_name = container_name
      end

      def import(tmpdir, miq_domain)
        commands =  [
          "rake evm:automate:import DOMAIN=#{miq_domain} IMPORT_DIR=#{tmpdir}/automate OVERWRITE=true PREVIEW=false ENABLED=true"
        ]
        $logger.debug('Importing with Appliance provider')
        commands.each do |cmd|
          system(cmd)
        end
      end

    end
  end
end
