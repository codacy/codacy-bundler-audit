module Codacy
  module BundlerAudit
    module Patterns

      class Pattern
        attr_reader :filename, :pattern_id

        def initialize(pattern_id, filename)
          @pattern_id = pattern_id
          @filename = filename
        end

        def to_json(*a)
          {
              filename: @filename,
              message: self.message,
              patternId: @pattern_id,
              line: self.line
          }.to_json(*a)
        end
      end

      class UnpatchedGem < Pattern
        PATTERN_ID = "Insecure Dependency".freeze

        # @param [Bundler::Audit::Scanner::UnpatchedGem] issue
        def initialize(issue, filename)
          super(PATTERN_ID, filename)
          @issue = issue
          @filename = filename
        end

        def message
          # TODO
          'UnpatchedGem'
        end

        def line
          # TODO
          2
        end
      end

      class InsecureSource < Pattern
        PATTERN_ID = "Insecure Source".freeze

        # @param [Bundler::Audit::Scanner::InsecureSource] issue
        def initialize(issue, filename)
          super(PATTERN_ID, filename)
          @issue = issue
        end

        def message
          # TODO
          'InsecureSource'
        end

        def line
          # TODO
          1
        end
      end
    end
  end
end
