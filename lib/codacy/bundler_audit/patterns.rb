module Codacy
  module BundlerAudit
    module Patterns
      ALL_PATTERNS = [UnpatchedGem::PATTERN_ID, InsecureSource::PATTERN_ID]

      class Pattern
        attr_reader :file_path, :pattern_id

        def initialize(pattern_id, file_path, file_lines, line_regex, regex_match_comp)
          @pattern_id = pattern_id
          @file_path = file_path
          @file_lines = file_lines
          @line_regex = line_regex
          @regex_match_comp = regex_match_comp
        end

        def to_json(*a)
          {
              file_path: @file_path,
              message: self.message,
              patternId: @pattern_id,
              line: self.line
          }.to_json(*a)
        end

        def line
          @line_number ||= begin
            @file_lines.find_index do |line|
              (match = @line_regex.match(line)) && match['comp'] == @regex_match_comp
            end + 1
          end
        end
      end

      class UnpatchedGem < Pattern
        PATTERN_ID = "Insecure Dependency".freeze
        LINE_REGEX = /^\s*(?<comp>\S+) \([\S.]+\)$/.freeze

        # @param [Bundler::Audit::Scanner::UnpatchedGem] issue
        # @param [String] file_path
        def initialize(issue, file_path, file_lines)
          super(PATTERN_ID, file_path, file_lines, LINE_REGEX, issue.gem.name)
          @issue = issue
          @file_path = file_path
        end

        def message
          "#{@issue.advisory.title} (#{@issue.advisory.id})"
        end
      end

      class InsecureSource < Pattern
        PATTERN_ID = "Insecure Source".freeze
        LINE_REGEX = /^\s*remote: (?<comp>\S+)$/.freeze

        # @param [Bundler::Audit::Scanner::InsecureSource] issue
        def initialize(issue, file_path, file_lines)
          super(PATTERN_ID, file_path, file_lines, LINE_REGEX, issue.source)
          @issue = issue
        end

        def message
          "Insecure Source URI found: #{@issue.source}"
        end
      end

    end
  end
end
