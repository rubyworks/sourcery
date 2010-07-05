module Till

  class Inline

    require 'till/inline/type'

    #
    class Cpp < Type

      EXTENSIONS = %w{ .c .cpp }

      def self.extensions ; EXTENSIONS ; end

      def self.start(line)
        if /^(\s*)(.*?)(\s*\/(\/|\*)\s*\:till(\+\d*)?\:\s*)/ =~ line
          new($&, $1, $2, $3, $4, $')
        end
      end

      def stop?(line)
        if marker =~ /\/\*/
          if /^.*?\*\// =~ line
            $&
          end
        else
          if /^\s*\#\s*:end:/ =~ line
            $&
          elsif /^\s*(?!:\/\/)/ =~ line
            true
          end
        end
      end

    end

  end

end

