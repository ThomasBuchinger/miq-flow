module GitFlow
  # MiqProvider implement the actual communication to ManageIQ
  # This depends the choosen deployment scenario for ManageIQ (e.g. Appliance)
  module MiqProvider
    # This provider does nothing, but it is useful for testing 
    class Noop


      def initialize(opts={})
      end

      def import(tmpdir, fs_domain, miq_domain)
        $logger.info("Importing with NOOP provider MIQ_DOMAIN=#{miq_domain} TMPDIR=#{tmpdir}")
      end

    end
  end
end
