module Rod
  class StringElement
    def self.page_offsets
      @page_offsets ||= []
    end

    def self.typedef_struct
      #"typedef struct {char value;} _string_element;"
      ""
    end

    def self.struct_name
      #"_string_element"
      "char"
    end

    def self.layout
    end

    def self.fields
      []
    end
  end
end
