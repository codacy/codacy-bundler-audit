require 'bundler/audit/scanner'
require 'codacy/config'
require 'codacy/bundler_audit/patterns'

module Codacy
  module BundlerAudit
    class App
      # @param [Codacy::BundlerAudit::CodacyConfig] config
      def run(config)
        config.files
            .select {|file| File.basename(file) == 'Gemfile.lock'}
            .flat_map {|file| run_in_dir(File.expand_path("..", file))
                                  .map {|issue| [issue, file]}.to_a}
            .map {|issue_file| convert_issue(issue_file[0], issue_file[1]).to_json}
      end

      # @param [String] source_root
      #   The path to the project root.
      def run_in_dir(source_root)
        Dir.chdir(source_root) do
          Bundler::Audit::Scanner.new.scan
        end
      end

      def convert_issue(issue, filename)
        case issue
        when Bundler::Audit::Scanner::UnpatchedGem
          Codacy::BundlerAudit::Patterns::UnpatchedGem.new(issue, filename)
        when Bundler::Audit::Scanner::InsecureSource
          Codacy::BundlerAudit::Patterns::InsecureSource.new(issue, filename)
        else
          #TODO handle error
        end
      end

    end
  end
end