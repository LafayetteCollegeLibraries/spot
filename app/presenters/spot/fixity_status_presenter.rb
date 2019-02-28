# frozen_string_literal: true
#
# Our own take on Hyrax::FixityStatusPresenter. We're hoping to
# present fixity info in a bootstrap .list-group style, and the
# sentence-format of the Hyrax presenter doesn't really allow this.
module Spot
  class FixityStatusPresenter < Hyrax::FixityStatusPresenter
    # Gives us access to the protected Hyrax::FixityStatusPresenter#render_existing_check_summary
    #
    # @return [String]
    def summary
      render_existing_check_summary
    end

    # Gives us access to the protected Hyrax::FixityStatusPresenter#relevant_log_records
    #
    # @return [Array<ChecksumAuditLog>]
    def log_records
      relevant_log_records
    end

    protected

      # @return [String]
      def render_existing_check_summary
        return 'Fixity checks have not yet been run on this object' if relevant_log_records.empty?
        super
      end
  end
end
