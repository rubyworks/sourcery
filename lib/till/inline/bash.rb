module Till

  require 'till/inline'

  class Bash < Inline

    EXTENSIONS = %w{ .sh }

    def self.extensions
      EXTENSIONS
    end

    #
    def render_result
      text = content
      text = render_backs(text)
      text = render_blocks(text)
    end

    #
    BACKS  = /^(\ *)(.*?)(\ *)(\#)(\ *)(:till)(\+\d*)?(:)(.*?\S.*?)$/

    #
    def render_backs(text)
      index  = 0
      result = ''

      text.scan(BACKS) do |m|
        md = $~

        indent = md[1]
        front  = md[2]
        remark = [ md[3], md[4], md[5], md[6], md[7], md[8], md[9] ].join('')
        tmplt  = md[9].strip
        count  = md[7]

        render = render_template(tmplt)

        result << text[index...md.begin(0)]
        result << format_backs(indent, front, remark, tmplt, render, count)

        #index = md.end(0)
        i = md.end(0) + 1
        count.to_i.times{ i = text[i..-1].index("\n") + i + 1 }
        index = i
      end

      result << text[index..-1]
      result
    end

    #
    def format_backs(indent, front, remark, tmplt, render, multi=nil)
      size = render.count("\n")
      if multi || size > 0
        indent + remark.sub(/:till(\+\d+)?:/, ":till+#{size+1}:") + "\n" + render
      else
        if tmplt =~ /^\s*\^/
          b = tmplt.index('^') + 1
          e = tmplt.index(/[<{]/) || - 1
          m = tmplt[b...e]
          i = front.index(m)
          render = front[0...i] + render.sub('^','')
        end
        "\n" + indent + render + remark.sub(/:till(\+\d+)?:/, ":till:") + "\n"
      end
    end

    #
    BLOCKS = /^(#=begin)(\s*)(:till)(\+\d*)?(\:)(\s*\n)((?m:^#.*?\n)*)(^#=end)/

    #
    def render_blocks(text)
      index  = 0
      result = ''

      text.scan(BLOCKS) do |m|
        md = $~

        #indent = ""
        #front  = nil
        remark = md[0]
        pad    = md[2]
        count  = md[4]
        tmplt  = md[7].rstrip.gsub(/^#/, '')

        render = render_template(tmplt)

        result << text[index...md.begin(0)]
        result << format_block(pad, tmplt, render)

        i = md.end(0) + 1
        count.to_i.times{ i = text[i..-1].index("\n") + i + 1 }
        index = i
      end

      result << text[index..-1]
      result
    end

    #
    def format_block(pad, template, render)
      size = render.count("\n") + 1
      temp = ''
      template.each_line do |line|
        temp << "# #{line}"
      end
      "#=begin#{pad}:till+#{size}:\n#{temp}\n#=end\n#{render}"
    end

  end

end

