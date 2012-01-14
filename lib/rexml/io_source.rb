# -*- coding: utf-8 -*-

module REXML
  class IOSource < Source
    def match(pattern, cons=false)
      # support UTF-8
      # add force_encoding('utf-8')
      rv = pattern.match(@buffer.force_encoding('utf-8'))
      @buffer = $' if cons and rv
      while !rv and @source
        begin
          @buffer << readline
          rv = pattern.match(@buffer)
          @buffer = $' if cons and rv
        rescue
          @source = nil
        end
      end
      rv.taint
      rv
    end
  end
end

