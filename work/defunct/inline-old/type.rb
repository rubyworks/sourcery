module Till

  class Inline

    # = Type Base Class
    #
    class Type

      # C L A S S - M E T H O D S

      #
      def self.map
        @map ||= (
          Type.register.inject({}) do |hash, base|
            base.extensions.each do |ext|
              hash[ext] = base
            end
            hash
          end
        )
      end

      def self.register
        @register ||= []
      end

      def self.inherited(base)
        register << base
      end

      def self.extensions ; raise ; end


      ## A T T R I B U T E S

      #attr :string
      #attr :indent
      #attr :front
      #attr :mark
      #attr :pad
      #attr :till
      #attr :count
      #attr :body
      #attr :post

      # Initialize a new type match.
      #def initialize(opts)
      #  @line   = opts[:line]
      #  @indent = opts[:indent]
      #  @front  = opts[:front]
      #  @mark   = opts[:mark]
      #  @pad    = opts[:pad]
      #  @till   = opts[:till]
      #  @count  = opts[:count].to_i
      #  @body   = opts[:body].strip
      #  @post   = opts[:post]
      #end

      ## Add a tail line.
      #def <<(line)
      #  @tail << line
      #end

      #
      #def to_s(result, cnt=nil)
      #  if cnt
      #    mark = marker.sub(/\+\d+/, "+#{cnt}")
      #    "#{indent}#{front}#{mark}#{tail}\n" + result  + "\n" # TODO: there should be no front
      #  elsif carrot?
      #    b = tail.index('^') + 1
      #    e = tail.index(/[<{]/) || - 1
      #    m = tail[b...e]
      #    i = front.index(m)
      #    result = front[0...i] + result.sub('^','')
      #    "#{indent}#{result}#{marker}#{tail}\n"
      #  else
      #    "#{indent}#{result}#{marker}#{tail}\n"
      #  end
      #end

      # Is a carrot matcher?
      def self.carrot?(render)
        /^\s*\^/.match(render)
      end

    end#class Type

  end#class Inline

end#module Till

