module Rod
  # This class allows for lazy fetching the objects from
  # a collection of Rod objects. It holds only a Ruby proc, which
  # called returns the object with given index.
  class CollectionProxy
    include Enumerable
    attr_reader :size
    alias count size

    # Intializes the proxy with +size+ of the collection
    # and +fetch+ block for retrieving the object from the database.
    def initialize(size,database,offset,klass)
      @size = size
      @original_size = size
      @database = database
      @klass = klass
      @offset = offset
      @appended = []
      @proxy = SimpleWeakHash.new
    end

    # Returns an object with given +index+.
    def [](index)
      return nil if index >= @size
      return @proxy[index] unless @proxy[index].nil?
      rod_id = id_for(index)
      result =
        if rod_id == 0
          nil
        else
          class_for(index).find_by_rod_id(rod_id)
        end
      @proxy[index] = result
    end

    # Appends element to the end of the collection.
    def <<(element)
      @appended << [element.rod_id,element.class]
      @size += 1
    end

    # Simple each implementation.
    def each
      if block_given?
        @size.times do |index|
          yield self[index]
        end
      else
        enum_for(:each)
      end
    end

    # Iterate over the rod_ids.
    def each_id
      if block_given?
        @size.times do |index|
          yield id_for(index)
        end
      else
        enum_for(:each_id)
      end
    end

    # String representation.
    def to_s
      "Proxy:[#{@size}][#{@original_size}]"
    end

    protected
    def id_for(index)
      if index >= @original_size && !@appended[index - @original_size].nil?
        @appended[index - @original_size][0]
      else
        if @klass.nil?
          @database.polymorphic_join_index(@offset,index)
        else
          @database.join_index(@offset,index)
        end
      end
    end

    def class_for(index)
      if index >= @original_size && !@appended[index - @original_size].nil?
        @appended[index - @original_size][1]
      else
        if @klass.nil?
          Model.get_class(@database.polymorphic_join_class(@offset,index))
        else
          @klass
        end
      end
    end
  end
end
