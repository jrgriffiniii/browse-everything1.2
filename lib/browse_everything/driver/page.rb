# frozen_string_literal: true
module BrowseEverything
  module Driver
    # Class modeling a Page of entries
    class Page
      ASC = 0
      DESC = 1

      attr_reader :children
      def initialize(index: 0, children: [])
        @index = index
        @children = children
      end

      def sort!
        sorted = if @order == ASC
                   @children.sort_by { |c| c.path.to_s }
                 else
                   @children.sort_by { |c| -c.path.to_s }
                 end

        @children = sorted
      end

      def <<(child)
        @children << child
        sort!
      end
    end
  end
end
