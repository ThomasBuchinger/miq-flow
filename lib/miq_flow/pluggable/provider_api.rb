# frozen_string_literal: true

module MiqFlow
  module MiqProvider
    # This provider assumes to be running on a ManageIQ Appliance
    class Api
      def initialize(_opts={})
        # fix rubocop issue #6678
        true
      end

      def import(miq_domain, opts)
        $logger.info('Importing with Api provider')
        # raise MiqFlow::ProviderError, 'Failed to Import to Appliance' unless success
      end
    end
  end
end
