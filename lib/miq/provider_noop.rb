# frozen_string_literal: true

module GitFlow
  # MiqProvider implement the actual communication to ManageIQ
  # This depends the choosen deployment scenario for ManageIQ (e.g. Appliance)
  module MiqProvider
    # This provider does nothing, but it is useful for testing
    class Noop
      def initialize(opts={})
        @fail = opts.fetch(:flag_fail, false)
      end

      def import(tmpdir, fs_domain, miq_domain)
        raise GitFlow::ProviderError, 'This provider cannot fail' if @fail

        $logger.info("Importing with NOOP provider MIQ_DOMAIN=#{miq_domain} TMPDIR=#{tmpdir} FS_DOMAIN=#{fs_domain}")
      end
    end
  end
end
