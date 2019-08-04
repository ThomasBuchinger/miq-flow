# frozen_string_literal: true

module MiqFlow
  module MiqProvider
    # This Provider uses 'docker exec' to communicate to ManageIQ
    # This Provider assumes, that a manageiq/manageiq continer is running on the local docker
    # host and the container is named 'mangeiq'. It is mostly used for development
    class Docker
      attr_accessor :container_name

      def initialize(container_name: 'manageiq')
        @container_name = container_name
      end

      def import(miq_domain, opts)
        tmpdir    = opts[:import_dir]
        fs_domain = opts[:fs_domain]
        $logger.debug("TMPDIR=#{tmpdir}")
        commands = [
          "docker exec #{@container_name} mkdir -p #{tmpdir}",
          "docker cp #{tmpdir}/. #{@container_name}:#{tmpdir}",
          "docker exec #{@container_name} /bin/bash --login -c 'rake evm:automate:import"\
          " DOMAIN=#{fs_domain} IMPORT_AS=#{miq_domain} IMPORT_DIR=#{tmpdir} OVERWRITE=true PREVIEW=false ENABLED=true'"
        ]
        $logger.info('Importing with Docker provider')
        success = commands.each do |cmd|
          system(cmd)
        end

        raise MiqFlow::ProviderError, 'Failed to Import to Miq Container' unless success
      end
    end
  end
end
