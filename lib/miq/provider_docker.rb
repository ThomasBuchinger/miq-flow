module GitFlow
  module MiqProvider
    class Docker

      attr_accessor :container_name

      def initialize(container_name: 'manageiq')
        @container_name = container_name
      end

      def import(tmpdir, fs_domain, miq_domain)
        commands =  [
          "docker cp #{tmpdir}/#{@automate_dir} #{@container_name}:#{tmpdir}",
          "docker exec #{@container_name} /bin/bash --login -c 'rake evm:automate:import DOMAIN=#{fs_domain} IMPORT_AS=#{miq_domain} IMPORT_DIR=#{tmpdir}/automate OVERWRITE=true PREVIEW=false ENABLED=true'"
        ]
        $logger.debug('Importing with Docker provider')
        commands.each do |cmd|
          system(cmd)
        end
      end

    end
  end
end
