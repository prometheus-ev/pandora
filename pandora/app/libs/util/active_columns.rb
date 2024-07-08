module Util
  module ActiveColumns
    PseudoColumn = Struct.new(:name, :human_name)

    module ClassMethods
      def columns_by_name(*names)
        @columns_by_name ||= begin
          columns_hash = HashWithIndifferentAccess.new do |h, k|
            PseudoColumn.new(k, k.to_s.tr('.', '_').humanize)
          end

          columns.each do |column|
            columns_hash[column.name] = column
          end

          columns_hash
        end

        names.empty? ? @columns_by_name : @columns_by_name.values_at(*names)
      end

      def column_by_name(name)
        columns_by_name[name]
      end

      def has_column?(name)
        table_exists? && columns_by_name.has_key?(name)
      end

      def reset_column_information
        super
        @columns_by_name = @list_columns = @search_columns = @display_columns = nil
      end

      def schema_changed!
        reset_column_information
      end

      def columns_for(key)
        c = pconfig if respond_to?(:pconfig)
        c &&= c[:columns_for]
        c &&= c[key]

        c.blank? ? [] : columns_by_name(*c)
      end

      def list_columns
        @list_columns ||= columns_for(:list)
      end

      def search_columns
        @search_columns ||= columns_for(:search)
      end

      def display_columns
        @display_columns ||= content_columns - columns_for(:display_exclude)
      end
    end


    class << self
      private

        def included(base)
          base.extend(ClassMethods)
        end
    end
  end
end
