module Till

  class Inline

    require 'till/inline/type'

    # = HTML Matcher
    #
    class Html < Type

      EXTENSIONS = %w{ .html }

      def self.extensions ; EXTENSIONS ; end

      def self.start(line)
        if /^(\s*)(.*?)(\s*(<!--)\s*\:till(\+\d*)?\:\s*)/ =~ line
          new($&, $1, $2, $3, $4, $')
        end
      end

      def stop?(line)
        if /-->/ =~ line
          $&
        end
      end

    end#class Html

  end#class Inline

end#module Till

