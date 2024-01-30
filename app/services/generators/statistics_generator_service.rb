# frozen_string_literal: true

module Generators
  class StatisticsGeneratorService
    # include Pundit::Helpers

    class << self
      # Generates csv
      # @param **head:** Csv header
      # @param **columns:** klass selected columns
      # @param **scopes:** Entity objects to export data as csv
      # @return generated csv data
      def handle_csv_generation(head, columns, scopes)
        CSV.generate(head, headers: true, col_sep: ';') do |csv|
          csv << columns
          map_klass_columns_attributes(scopes, columns, csv)
        end
      end

      # @param **obj:** Object to export data as csv
      # @param **columns:** obj selected columns
      def map_columns(obj, columns)
        columns.map { |attr| obj.send(attr) }
      end

      # map scopes columns attributes
      # @param **scopes:** Entity objects to export data as csv
      # @param **columns:** klass selected columns
      # @param **csv:** existing csv data
      def map_klass_columns_attributes(scopes, columns, csv)
        scopes.find_each do |obj|
          csv << map_columns(obj, columns)
        end
      end

      # Generates csv containing available columns on first line
      # then each column attribute value for klass object on a line
      # @param **klass:** Entity to export data as csv
      # @param **columns:** Entity selected columns
      # @param **scopes:** policy_scope(klass)
      # @return [filename, generated csv data]
      def generate_csv(klass, columns, scopes)
        filename = "#{klass}-#{Time.zone.today}.csv"

        # Add BOM to make excel using utf8 to open csv file
        # By default split uses ' '
        head = 'EF BB BF'.split.map { |a| a.hex.chr }.join

        data = handle_csv_generation(head, columns, scopes)
        [filename, data]
      end
    end
  end
end
