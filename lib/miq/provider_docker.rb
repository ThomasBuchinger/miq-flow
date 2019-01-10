# frozen_string_literal: true

module GitFlow
  module MiqProvider
    # This Provider uses 'docker exec' to communicate to ManageIQ
    # This Provider assumes, that a manageiq/manageiq continer is running on the local docker
    # host and the container is named 'mangeiq'. It is mostly used for development
    class Docker
      attr_accessor :container_name

      def initialize(container_name: 'manageiq')
        @container_name = container_name
      end

      def import(tmpdir, fs_domain, miq_domain)
        $logger.debug("TMPDIR=#{tmpdir}")
        commands = [
          "docker exec #{@container_name} mkdir -p #{tmpdir}",
          "docker cp #{tmpdir}/. #{@container_name}:#{tmpdir}",
          "docker exec #{@container_name} /bin/bash --login -c 'rake evm:automate:import"\
          " DOMAIN=#{fs_domain} IMPORT_AS=#{miq_domain} IMPORT_DIR=#{tmpdir} OVERWRITE=true PREVIEW=false ENABLED=true'"
        ]
        $logger.info('Importing with Docker provider')
        commands.each do |cmd|
          system(cmd)
        end
      end
    end
  end
end
