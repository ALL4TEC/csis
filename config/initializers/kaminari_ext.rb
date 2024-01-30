module Kaminari
    module Helpers
        class Paginator
            def render(&block)
                instance_eval(&block) if @options[:per_page] > PAGE_SIZES[0] && @options[:total_pages] >= 1 || @options[:total_pages] > 1
                @output_buffer
            end
        end
    end
end