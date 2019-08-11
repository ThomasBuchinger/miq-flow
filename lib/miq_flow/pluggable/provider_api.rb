# frozen_string_literal: true

module MiqFlow
  module MiqProvider
    # This provider assumes to be running on a ManageIQ Appliance
    class Api
      def initialize(_opts={})
        @api = MiqFlow::ManageIQ.new
      end

      def import(_miq_domain, opts)
        $logger.info("Importing with Api provider: #{opts[:ref_name]} from #{opts[:git_url]}")
        res = { git_url: opts[:git_url], ref_type: opts[:ref_type], ref_name: opts[:ref_name] }
        repo = opts[:repo]

        $logger.info("Push Domain: #{opts[:ref_name]} to git")
        repo.push_to_upstream

        $logger.info("Import to Automate")
        re = @api.miq_action_api('create_from_git', '/automate_domains', resource: res)
        $logger.debug("RestResult: #{re}")

        # $logger.info("Remove temporary branch...")
        # repo.delete_from_upstream
      end
    end
  end
end
