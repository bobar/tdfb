module BootstrapForm
  module Helpers
    def bootstrap_form_tag(options = {}, &block)
      options[:acts_like_form_tag] = true
      (options[:html] ||= {}).reverse_merge! autocomplete: 'off'

      bootstrap_form_for('', options, &block)
    end

    module Bootstrap
      def submit(name = nil, options = {}) # rubocop:disable Style/OptionHash
        (options[:data] ||= {}).reverse_merge! disable_with: '...'
        options.reverse_merge! class: 'btn btn-default'
        super(name, options)
      end

      def primary(name = nil, options = {}) # rubocop:disable Style/OptionHash
        (options[:data] ||= {}).reverse_merge! disable_with: '...'
        options.reverse_merge! class: 'btn btn-primary'
        submit(name, options)
      end
    end
  end
end
