# encoding: utf-8
require 'rod/index/base'

module Rod
  module Index
    # Class implementing segmented index, i.e. an index which allows for
    # lazy loading of its pieces.
    class FlatIndex < Base
      # Creats the index with given +path+ for given +klass+.
      # Options are not used in the case of FlatIndex.
      def initialize(path,klass,options={})
        super(klass)
        @path = path + ".idx"
        @index = nil
      end

      # Stores the index on disk.
      def save
        File.open(@path,"w") do |out|
          proxy_index = {}
          @index.each{|k,col| proxy_index[k] = [col.offset,col.size]}
          out.puts(Marshal.dump(proxy_index))
        end
      end

      # Destroys the index (removes it from the disk completely).
      def destroy
        remove_file(@path)
      end

      def each
        load_index unless loaded?
        if block_given?
          @index.each_key do |key|
            yield key, self[key]
          end
        else
          enum_for(:each)
        end
      end

      protected
      def get(key)
        load_index unless loaded?
        @index[key]
      end

      def set(key,value)
        load_index unless loaded?
        @index[key] = value
      end

      def loaded?
        !@index.nil?
      end

      def load_index
        begin
          File.open(@path) do |input|
            if input.size == 0
              @index = {}
            else
              @index = Marshal.load(input)
            end
          end
        rescue Errno::ENOENT
          @index = {}
        end
      end
    end # class FlatIndex
  end # module Index
end # module Rod
