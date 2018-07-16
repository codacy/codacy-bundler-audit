require 'find'
require 'set'
require 'pathname'
require 'codacy/config'
require 'codacy/bundler_audit/patterns'

module Codacy
  module BundlerAudit
    class ConfigHelper
      CONFIG_FILENAME = '.codacy.json'.freeze
      TOOL_NAME = 'bundleraudit'.freeze
      ALL_PATTERNS_IDS = Set[Patterns::UnpatchedGem::PATTERN_ID,
                             Patterns::InsecureSource::PATTERN_ID].freeze

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
        @gem_files ||= Dir.chdir(@root) do
          Dir.glob("**/Gemfile.lock").to_set
        end
      end

      def patterns
        Codacy::BundlerAudit::ConfigHelper::ALL_PATTERNS_IDS
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
                .to_set
      end

      def patterns
        @patterns ||= config_patterns_or_default
      end

      private

      def config_patterns_or_default
        tool = @config.tools
                   .find {|tool| tool.name == ConfigHelper::TOOL_NAME}

        if tool
          tool.patterns.map {|pattern| pattern.pattern_id}.to_set
        else
          Codacy::BundlerAudit::ConfigHelper::ALL_PATTERNS_IDS
        end
      end
    end
  end
end
