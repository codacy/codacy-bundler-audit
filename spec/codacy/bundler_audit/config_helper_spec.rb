require 'tmpdir'
require 'spec_helper.rb'
require 'codacy/bundler_audit/app'

module Codacy
  module BundlerAudit
    ALL_PATTERNS = [Codacy::BundlerAudit::Patterns::InsecureSource::PATTERN_ID,
                    Codacy::BundlerAudit::Patterns::UnpatchedGem::PATTERN_ID]

    RSpec.describe Codacy::BundlerAudit::ConfigHelper do

      it "parses a complete configuration successfully" do
        with_tmp_config('complete_config.json') do |dir|
          config = Codacy::BundlerAudit::ConfigHelper.parse_config(dir)

          expect(config.gem_files).to contain_exactly('insecure_sources/Gemfile.lock',
                                                      'unpatched_gems/Gemfile.lock')

          expect(config.patterns).to contain_exactly(Codacy::BundlerAudit::Patterns::InsecureSource::PATTERN_ID)
        end
      end

      it "parses the configuration without the tool specified, returning all patterns" do
        with_tmp_config('config_without_tool.json') do |dir|
          config = Codacy::BundlerAudit::ConfigHelper.parse_config(dir)

          expect(config.gem_files).to contain_exactly('insecure_sources/Gemfile.lock',
                                                      'unpatched_gems/Gemfile.lock')

          expect(config.patterns).to contain_exactly(*ALL_PATTERNS)
        end
      end

      it "parses the configuration without the patterns specified, returning all patterns" do
        with_tmp_config('config_with_null_patterns.json') do |dir|
          config = Codacy::BundlerAudit::ConfigHelper.parse_config(dir)

          expect(config.gem_files).to contain_exactly('insecure_sources/Gemfile.lock',
                                                      'unpatched_gems/Gemfile.lock')

          expect(config.patterns).to contain_exactly(*ALL_PATTERNS)
        end
      end

      it "parses the configuration with empty patterns list, returning no patterns" do
        with_tmp_config('config_with_empty_patterns.json') do |dir|
          config = Codacy::BundlerAudit::ConfigHelper.parse_config(dir)

          expect(config.gem_files).to contain_exactly('insecure_sources/Gemfile.lock',
                                                      'unpatched_gems/Gemfile.lock')

          expect(config.patterns).to be_empty
        end
      end

      it "creates a configuration with all patterns when no configuration file exists" do
        Dir.mktmpdir do |dir|
          config = Codacy::BundlerAudit::ConfigHelper.parse_config(dir)

          expect(config.gem_files).to be_empty

          expect(config.patterns).to contain_exactly(*ALL_PATTERNS)
        end
      end

      it "creates a configuration with a single Gemfile.lock file when no configuration file exists" do
        Dir.mktmpdir do |dir|
          FileUtils.touch(File.join(dir, 'Gemfile.lock'))

          config = Codacy::BundlerAudit::ConfigHelper.parse_config(dir)

          expect(config.gem_files).to contain_exactly('Gemfile.lock')

          expect(config.patterns).to contain_exactly(*ALL_PATTERNS)
        end
      end

      it "creates a configuration with all Gemfile.lock files when no configuration file exists" do
        Dir.mktmpdir do |dir|
          FileUtils.touch(File.join(dir, 'Gemfile.lock'))
          FileUtils.mkdir(File.join(dir, 'other_dir'))
          FileUtils.touch(File.join(dir, 'other_dir/Gemfile.lock'))

          config = Codacy::BundlerAudit::ConfigHelper.parse_config(dir)

          expect(config.gem_files).to contain_exactly('Gemfile.lock',
                                                      'other_dir/Gemfile.lock')

          expect(config.patterns).to contain_exactly(*ALL_PATTERNS)
        end
      end

      def with_tmp_config(config_file)
        Dir.mktmpdir do |dir|
          FileUtils.cp(File.join('spec/resources/codacy_config/', config_file),
                       File.join(dir, ".codacy.json"))
          yield(dir)
        end
      end

    end
  end
end
