module GitFlow
  module MiqProvider
    class Noop


      def initialize(opts={})
      end

      def import(tmpdir, fs_domain, miq_domain)
        $logger.debug("Importing with NOOP provider MIQ_DOMAIN=#{miq_domain} TMPDIR=#{tmpdir}")
      end

    end
  end
end
