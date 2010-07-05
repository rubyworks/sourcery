module Till
module Inline

    require 'till/inline/type'

    #
    class Javascript < Parser

      EXTENSIONS = %w{ .js }

      LINE_BACK  = /^(\s*)(.*?)(\s*\/\/\s*\:till)(\+\d*)?(\:)(.*?\S.*?)$/

      LINE_BLOCK = /^(\ *)(.*?)(\ *\/\/\ *\:till(\+\d*)?(\:)(\s*\n))((?m:\/\/.*?\n)*)(\/\/[ \t]*:end:)/

      BLOCK      = /^(.*?)\/\*(\s*\:till(\+\d*)?\:)(?m:.*?)\*\//

      def extensions
        EXTENSIONS
      end

      def parse(text)
        text = parse_line_backs(text)
        text = parse_line_blocks(text)
        text = parse_blocks(text)
      end

      def parse_lines_backs(text)
        text.gsub(LINE_BACK) do |m|
          indent = $1
          front  = $2
          remark = $3 + $4.to_s + $5 + $6
          render = $6.strip
          count  = $4
          #offset = 1
          result = render_template(render)
          format(indent, front, remark, result, count)
        end
      end

      def parse_line_blocks(text)
        text.gsub(LINE_BLOCK) do |m|
          indent = $1
          front  = $2
          remark = $3 + $4.to_s + $5 +$6
          render = $7.strip.gsub(/^\s*\/\//, '')
          count  = $3
          result = render_template(render)
          format(indent, front, remark, result, count)
        end
      end

      def parse_blocks(text)
        text.gsub(BLOCK) do |m|
          indent = $1
          front  = nil
          remark = $2 + $3.to_s + $4 + $5
          render = $5.strip
          count  = $3
          result = render_template(render)
          format(indent, front, remark, result, count)
        end
      end

      #
      def format(indent, front, remark, render, multi=nil)
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

    end#class Javascript

end#module Inline
end#module Till

