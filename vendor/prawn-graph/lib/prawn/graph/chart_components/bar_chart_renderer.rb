module Prawn
  module Graph
    module ChartComponents
      # The Prawn::Graph::ChartComponents::BarChartRenderer is used to plot one or more bar charts 
      # in a sensible way on a a Prawn::Graph::ChartComponents::Canvas and its associated 
      # Prawn::Document.
      #
      class BarChartRenderer < SeriesRenderer
        def render
          render_the_chart
        end

        private

        def mark_average_line(series_index)
          if @series[series_index].mark_average?
            average_y_coordinate = (point_height_percentage(@series[series_index].avg) * @plot_area_height) - 5
            prawn.line_width = 1
            prawn.stroke_color =  @canvas.theme.color_for(@series[series_index]) # @color[series_index]
            prawn.dash(2)
            prawn.stroke_line([0, average_y_coordinate], [ @plot_area_width, average_y_coordinate ])
            prawn.undash
          end
        end

        def mark_maximum_point(series_index, point, max_marked, x_position, y_position)
          if @series[series_index].mark_maximum? && max_marked == false && @series[series_index].values[point] == @series[series_index].max
            max_marked = draw_marker_point(@canvas.theme.max, x_position, y_position)
          end

          max_marked
        end

        def mark_minimum_point(series_index, point, min_marked, x_position, y_position)
          if @series[series_index].mark_minimum? && min_marked == false && !@series[series_index].values[point].zero? && @series[series_index].values[point] == @series[series_index].min
            min_marked = draw_marker_point(@canvas.theme.min, x_position, y_position)
          end

          min_marked
        end

        def render_the_chart
          prawn.bounding_box [@graph_area.point[0] + 5, @graph_area.point[1] - 20], width: @plot_area_width, height: @plot_area_height do
         
            prawn.save_graphics_state do  
              num_points        = @series[0].size
              width_per_point   = (@plot_area_width / num_points)
              width             = (((width_per_point * 0.9) / @series.size).round(2)).to_f
              min_marked        = false
              max_marked        = false

              num_points.times do |point|

                @series.size.times do |series_index|
                  series_offset = series_index + 1
                  prawn.fill_color    = @canvas.theme.color_for(@series[series_index])
                  prawn.stroke_color  = @canvas.theme.color_for(@series[series_index])
                  prawn.line_width  = width

                  starting = (prawn.bounds.left + (point * width_per_point))

                  x_position = ( (starting + (series_offset * width) ).to_f - (width / 2.0))
                  y_position = ((point_height_percentage(@series[series_index].values[point]) * @plot_area_height) - 5).to_f

                  prawn.fill_and_stroke_line([ x_position ,0], [x_position ,y_position]) unless @series[series_index].values[point].zero?

                  mark_average_line(series_index)
                  max_marked = mark_maximum_point(series_index, point, max_marked, x_position, y_position)
                  min_marked = mark_minimum_point(series_index, point, min_marked, x_position, y_position)
                end

              end

            end
            render_axes
          end
        end

        def max 
          @series.map(&:max).max || 0
        end

        def min
          @series.map(&:min).min || 0
        end

        def avg
          @series.map(&:avg).inject(:+) / @series.size rescue 0
        end

      end
    end
  end
end