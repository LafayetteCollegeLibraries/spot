# frozen_string_literal: true
module Spot
  module ExportsImageDerivatives
    extend ActiveSupport::Concern

    included do
      class_attribute :derivative_size_parameters
      self.derivative_size_parameters = {
        'full' => 'full',
        'large' => '!1200,1200',
        'medium' => '!900,900',
        'small' => '!600,600'
      }
    end

    # @return [Array<Array<String>>]
    def image_derivative_options
      derivative_size_parameters.map do |key, param|
        [
          I18n.translate("spot.work.export.image_sizes.#{key}", default: key.titleize),
          download_url_for(size: param, filename: "#{id}-#{key}.jpg")
        ]
      end
    end

  private

    # @return [String]
    def download_url_for(size:, filename:)
      Spot::IiifService.download_url(file_id: representative_id, size: size, filename: filename)
    end
  end
end
