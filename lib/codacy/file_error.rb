require 'json'

module Codacy
  class FileError
    def initialize(filename, message)
      @filename = filename
      @message = message
    end

    def to_json(*a)
      {
          filename: @filename,
          message: @message,
      }.to_json(*a)
    end

  end
end