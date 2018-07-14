require 'bundler/audit/scanner'
require 'codacy/config'
require 'codacy/bundler_audit/patterns'
require 'codacy/bundler_audit/config_helper'
require 'set'

module Codacy
  module BundlerAudit
    class App

      def run(project_root)
        config = Codacy::BundlerAudit::ConfigHelper.parse_config(Dir.pwd)

        run_with_config(project_root, config)
            .each {|issue| STDOUT.print("#{issue.to_json}\n\0")}
      end


      def run_with_config(config, project_root)
        Dir.chdir(project_root) do
          files_read_cache = Hash.new {|h, key| h[key] = read_file_lines(key)}

          config
              .gem_files
              .flat_map {|file| run_tool_in_dir(File.expand_path("..", file), config)
                                    .map {|issue| [issue, file]}.to_a}
              .map {|issue_file| convert_issue(issue_file[0], issue_file[1], files_read_cache[issue_file[1]])}
        end
      end

      def read_file_lines(file)
        File.open(file).each_line.to_a
      end

      # @param [String] directory
      #   The path to the project root.
      def run_tool_in_dir(directory, config)
        Dir.chdir(directory) do
          run_with_patterns(config.patterns)
        end
      end

      def run_with_patterns(patterns)
        case patterns.to_set
        when Set[Patterns::InsecureSource::PATTERN_ID, Patterns::UnpatchedGem::PATTERN_ID]
          Bundler::Audit::Scanner.new.scan
        when Set[Patterns::InsecureSource::PATTERN_ID]
          Bundler::Audit::Scanner.new.scan_sources
        when Set[Patterns::UnpatchedGem::PATTERN_ID]
          Bundler::Audit::Scanner.new.scan_specs
        else
          # TODO handle error
        end
      end

      def convert_issue(issue, filename, file_lines)
        case issue
        when Bundler::Audit::Scanner::UnpatchedGem
          Codacy::BundlerAudit::Patterns::UnpatchedGem.new(issue, filename, file_lines)
        when Bundler::Audit::Scanner::InsecureSource
          Codacy::BundlerAudit::Patterns::InsecureSource.new(issue, filename, file_lines)
        else
          #TODO handle error
        end
      end

    end
  end
end