require 'json'

module Codacy
  class Config
    attr_reader :json, :files, :tools

    def initialize(json)
      @json = json
      @files = @json["files"]
      @tools = @json["tools"]&.map {|tool| Tool.new(tool)}
    end

    class << Config
      def parse_file(file_path)
        parse(File.read(file_path))
      end

      def parse(raw_json)
        Config.new(JSON.parse(raw_json))
      end
    end
  end
end

class Tool
  attr_reader :json, :name, :patterns

  def initialize(json)
    @json = json
    @name = @json["name"]
    @patterns = @json["patterns"]&.map {|pattern| Pattern.new(pattern)}
  end
end

class Pattern
  attr_reader :json, :pattern_id, :parameters

  def initialize(json)
    @json = json
    @pattern_id = @json["patternId"]
    @parameters = @json["parameters"]
  end
end