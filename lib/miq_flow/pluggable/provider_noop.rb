# frozen_string_literal: true

module MiqFlow
  # MiqProvider implement the actual communication to ManageIQ
  # This depends the choosen deployment scenario for ManageIQ (e.g. Appliance)
  module MiqProvider
    # This provider does nothing, but it is useful for testing
    class Noop
      def initialize(opts={})
        @fail = opts.fetch(:flag_fail, false)
      end

      def import(miq_domain, opts)
        raise MiqFlow::ProviderError, 'This provider cannot fail' if @fail

        $logger.info("Importing with NOOP provider MIQ_DOMAIN=#{miq_domain} options=#{opts}")
      end
    end
  end
end
