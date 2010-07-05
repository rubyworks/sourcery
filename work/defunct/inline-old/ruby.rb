module Till

  class Inline

    require 'till/inline/type'

    # = Ruby Script Matcher
    #
    # TODO: Add =begin ... =end matching

    class Ruby < Type

      EXTENSIONS = %w{ .rb }

      #PATTERNS   = [
      #  /^(.*?)\#([ \t]*\:till(\+\d*)?\:)(.*?\S.*?)$/,
      #  /^(.*?)\#([ \t]*\:till(\+\d*)?\:)[ \t]*\n(?m:.*?)\#[ \t]*\:end\:/,
      #  /^=begin\s*\:till\:(.*?)^=end/m 
      #]

      def self.extensions ; EXTENSIONS ; end

      def self.start?(line)
        /\#\s*\:till(\+\d*)?\:/ =~ line
      end

      def self.parse(lines, index)
        line = lines[index]

        case line
        when /^(\s*)(.*?)(\s*\#\s*\:till)(\+\d*)?(\:)(.*?\S.*?)$/
          indent = $1
          front  = $2
          remark = $3 + $4.to_s + $5 + $6
          render = $6.strip
          count  = $4
          offset = 1

          [indent, front, remark, render, count, offset]

        when /^(\s*)(\#\s*\:till)(\+\d*)?(\:)(\s*)$/
          indent = $1
          front  = nil
          remark = $2 + $3.to_s + $4 + $5
          render = $5.strip
          count  = $3

          i, s = index + 1, nil
          until s or i == lines.size
            remain = lines[i]
            s = stop?(remain)
            i += 1
          end

          remark = remark + lines[index+1...i].join("\n")
          render = render + lines[index+1...i].join("\n")

          [indent, front, remark, render, count, i]
        end
      end

      #
      def self.stop?(line)
        if md = /^(\s*)(\#\s*:end:)/.match(line)
          [md, true]
        elsif md = /^(\s*)[^#]/.match(line)
          [md, false]
        end
      end

      #
      def self.format(indent, front, remark, render, multi=nil)
        size = render.count("\n")
        if multi || size > 0
          indent + remark.sub(/:till(\+\d+)?:/, ":till+#{size}:") + "\n" + render
        else
          if render =~ /^\s*\^/
            b = render.index('^') + 1
            e = render.index(/[<{]/) || - 1
            m = render[b...e]
            i = front.index(m)
            render = front[0...i] + render.sub('^','')
          end
          "\n" + indent + render + remark.sub(/:till(\+\d+)?:/, ":till:") + "\n"
        end
      end

    end#class Ruby

  end#class Inline

end#module Till



=begin
    #
    class Javascript < Type
      EXTENSIONS = %w{ .js }
      PATTERNS   = [
        /^(.*?)\/\/([ \t]*\:till(\+\d*)?\:)(.*?\S.*?)$/,
        /^(.*?)\/\/([ \t]*\:till(\+\d*)?\:)[ \t]*\n(?m:.*?)\/\/[ \t]*\:end\:/,
        /^(.*?)\/\*(\s*\:till(\+\d*)?\:)(?m:.*?)\*\//
      ]

      def self.extensions ; EXTENSIONS ; end
      def self.patterns   ; PATTERNS   ; end
    end


    #
    class Cpp < Type
      EXTENSIONS = %w{ .c .cpp }
      PATTERNS   = [
        /^(.*?)\/\/([ \t]*\:till(\+\d*)?\:)(.*?\S.*?)$/,
        /^(.*?)\/\/([ \t]*\:till(\+\d*)?\:)[ \t]*\n(?m:.*?)\/\/[ \t]*\:end\:/,
        /^(.*?)\/\*(\s*\:till(\+\d*)?\:)(?m:.*?)\*\//
      ]

      def self.extensions ; EXTENSIONS ; end
      def self.patterns   ; PATTERNS   ; end
    end


    #
    class SGML < Type
      EXTENSIONS = %w{ .html }
      PATTERNS   = [
        /^(.*?)<!--(\s*\:till(\+\d*)?\:)(?m:.*?)-->/
      ]

      def self.extensions ; EXTENSIONS ; end
      def self.patterns   ; PATTERNS   ; end
    end

    #
    class CSS < Type
      EXTENSIONS = %w{ .css }
      PATTERNS   = [
        /^(.*?)\/\*(\s*\:till(\+\d*)?\:)(?m:.*?)\*\//
      ]

      def self.extensions ; EXTENSIONS ; end
      def self.patterns   ; PATTERNS   ; end
    end
=end

