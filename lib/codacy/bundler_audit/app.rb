require 'bundler/audit/scanner'
require 'codacy/config'
require 'codacy/bundler_audit/patterns'

module Codacy
  module BundlerAudit
    class App
      # @param [Codacy::BundlerAudit::CodacyConfig] config
      def run(config)
        files_read = Hash.new {|h, key| h[key] = read_file_lines(key).to_a}

        config.files
            .select {|file| File.basename(file) == 'Gemfile.lock'}
            .flat_map {|file| run_in_dir(File.expand_path("..", file))
                                  .map {|issue| [issue, file]}.to_a}
            .map {|issue_file| convert_issue(issue_file[0], issue_file[1], files_read[issue_file[1]]).to_json}
      end

      # @param [String] source_root
      #   The path to the project root.
      def run_in_dir(source_root)
        Dir.chdir(source_root) do
          Bundler::Audit::Scanner.new.scan
        end
      end

      def read_file_lines(file)
        File.open(file).each_line
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