require "bundler/audit/scanner"
require "codacy/config"
require "codacy/file_error"
require "codacy/bundler_audit/patterns"
require "codacy/bundler_audit/config_helper"
require "set"

module Codacy
  module BundlerAudit
    class App
      def run(project_root)
        disable_bundler_audit_network

        Dir.chdir(project_root) do
          config = Codacy::BundlerAudit::ConfigHelper.parse_config("/")

          run_with_config(config)
            .each { |issue| STDOUT.print("#{issue.to_json}\n") }
        end
      end

      def disable_bundler_audit_network
        Bundler::Audit::Scanner.module_eval do
          def internal_source?(_uri)
            false
          end
        end
      end

      def run_with_config(config)
        files_read_cache = Hash.new { |h, key| h[key] = read_file_lines(key) }

        config
          .gem_files
          .flat_map { |file|
          run_tool_in_dir(File.expand_path("..", file), config)
            .map { |issue| [issue, file] }.to_a
        }
          .map { |issue_file| convert_issue_or_error(issue_file[0], issue_file[1], files_read_cache[issue_file[1]]) }
      end

      def read_file_lines(file)
        File.open(file).each_line.to_a
      end

      # @param [String] directory
      #   The path to the project root.
      def run_tool_in_dir(directory, config)
        if Dir.exist?(directory) == false then []
        else
          Dir.chdir(directory) do
            run_with_patterns(config.patterns, directory)   
          end
        end
      end

      def run_with_patterns(patterns, directory)
        set = patterns.to_set
        filename = File.join(directory, "Gemfile.lock")

        begin
          if set == Set[Patterns::InsecureSource::PATTERN_ID, Patterns::UnpatchedGem::PATTERN_ID]
            Bundler::Audit::Scanner.new.scan
          elsif set == Set[Patterns::InsecureSource::PATTERN_ID]
            Bundler::Audit::Scanner.new.scan_sources
          elsif set == Set[Patterns::UnpatchedGem::PATTERN_ID]
            Bundler::Audit::Scanner.new.scan_specs
          elsif set.empty?
            []
          else
            [Codacy::FileError.new(filename, "Unexpected patterns to use: #{patterns.to_a}")]
          end
        rescue StandardError => err
          [Codacy::FileError.new(filename, "Error calling bundler-audit: #{err.to_s}")]
        end
      end

      def convert_issue_or_error(issue_or_error, filename, file_lines)
        case issue_or_error
        when Bundler::Audit::Results::UnpatchedGem
          Codacy::BundlerAudit::Patterns::UnpatchedGem.new(issue_or_error, filename, file_lines)
        when Bundler::Audit::Results::InsecureSource
          Codacy::BundlerAudit::Patterns::InsecureSource.new(issue_or_error, filename, file_lines)
        when Codacy::FileError
          issue_or_error
        else
          Codacy::FileError.new(filename, "Unexpected result from tool: #{issue_or_error}")
        end
      end
    end
  end
end
