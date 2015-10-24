require 'pathname'

module DryRequireSpecHelper
  class Core
    def initialize(target_path)
      @target = Pathname(target_path)
    end

    def valid?
      File.exist?(@target.join('.rspec'))
    end

    def append_require_options
      helper_name = used_rails_helper? ? 'rails_helper' : 'spec_helper'

      File.open(@target.join('.rspec'), 'a') {|file| file.write("--require #{helper_name}\n") }
    end

    def remove_require_spec_helper
      Dir[@target.join('./spec/**/*_spec.rb')].each do |path|
        source = File.read(path)

        next unless /require +('(spec|rails)_helper'|"(spec|rails)_helper")\n*/ === source

        source.gsub!($&, '')

        File.open(path, 'w+') {|f| f.write(source) }
      end
    end

    private

    def used_rails_helper?
      File.exists?(@target.join('spec/rails_helper.rb')) &&
        File.exist?(@target.join('Gemfile.lock')) &&
        File.read(@target.join('Gemfile.lock')).split("\n").detect {|gem| /rspec-rails \((\d)\.(\d)\.(\d)([0-9A-Za-z-]*)\)\z/ === gem } &&
        $1.to_i >= 3
    end
  end
end
