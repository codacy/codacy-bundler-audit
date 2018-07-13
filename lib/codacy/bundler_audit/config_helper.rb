require 'find'

module Codacy
  module BundlerAudit
    class ConfigHelper
      CONFIG_FILENAME = ".codacy.config".freeze

      class << ConfigHelper
        def parse_config(root)
          config_file_path = File.join(root, CONFIG_FILENAME)

          if File.exist?(config_file_path)
            WithConfigFile.new(config_file_path)
          else
            NoConfigFile.new(root)
          end
        end
      end
    end

    class NoConfigFile
      def initialize(root)
        @root = root
      end

      def gem_files
        @gem_files ||= Dir.glob("#{@root}/**/Gemfile.lock")
      end

      def patterns
        Codacy::BundlerAudit::Patterns::ALL_PATTERNS
      end
    end

    class WithConfigFile

      def initialize(config_file_path)
        @config = Codacy::Config.parse_file(config_file_path)
      end

      def gem_files
        @gem_files ||=
            @config.files
                .select {|file| File.basename(file) == 'Gemfile.lock'}
      end

      def patterns
        @patterns ||=
            @config.tools
                .find {|tool| tool.name == "bundler-audit"}
                .patterns
      end
    end
  end
end
