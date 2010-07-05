module Till

  class Inline

    require 'till/inline/type'

    # = Base Script Matcher
    #
    class Bash < Type
      EXTENSIONS = %w{ .sh }
      #PATTERNS   = [
      #  /^(.*?)\#([ \t]*\:till(\+\d*)?\:)(.*?\S.*?)$/,
      #  /^(.*?)\#([ \t]*\:till(\+\d*)?\:)[ \t]*\n(?m:.*?)\#[ \t]*\:end\:/,
      #]

      def self.extensions ; EXTENSIONS ; end

      def self.start?(line)
        if /^(\s*)(.*?)(\s*\#\s*\:till(\+\d*)?\:\s*)/ =~ line
          new($&, $1, $2, $3, $4, $')
        end
      end

      def stop?(line)
        if /^\s*\#\s*:end:/ =~ line
          $&
        elsif /^\s*[^#]/ =~ line
          true
        end
      end
    end

  end

end

