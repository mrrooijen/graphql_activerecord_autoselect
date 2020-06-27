# frozen_string_literal: true

require "graphql_activerecord_autoselect/version"
require "active_record"

module GraphQLActiveRecordAutoSelect
  extend self

  refine ::ActiveRecord::Base.singleton_class do
    def autoselect(lookahead, dependents = {})
      select(
        GraphQLActiveRecordAutoSelect.call(
          :model      => self,
          :lookahead  => lookahead,
          :dependents => dependents,
        )
      )
    end
  end

  refine ::ActiveRecord::Relation do
    def autoselect(lookahead, dependents = {})
      select(
        GraphQLActiveRecordAutoSelect.call(
          :model      => model,
          :lookahead  => lookahead,
          :dependents => dependents
        )
      )
    end
  end

  def call(model:, lookahead:, dependents:)
    primary_key = model.primary_key
    columns     = model.column_names
    fields      = get_fields(lookahead)

    Array.new.tap do |selection|
      selection.concat filter_by_columns(fields, columns)
      selection.concat include_identifier_columns(primary_key, columns)
      selection.concat include_dependents(fields, dependents)
      selection.compact!
      selection.uniq!
    end
  end

  private

  def filter_by_columns(fields, columns)
    fields.select { |name| columns.include?(name) }
  end

  def include_identifier_columns(primary_key, columns)
    columns.select do |name|
      name == primary_key || name == "type" || name.end_with?("_type") || name.end_with?("_id")
    end
  end

  def include_dependents(fields, dependents)
    dependents.reduce([]) do |selection, (field, columns)|
      if fields.include?(field.to_s)
        selection + columns.map(&:to_s)
      else
        selection
      end
    end
  end

  def get_fields(lookahead)
    get_selections(lookahead).map(&:name).map(&:to_s)
  end

  def get_selections(lookahead)
    if lookahead.selection(:edges).selects?(:node)
      lookahead.selection(:edges).selection(:node).selections
    elsif lookahead.selects?(:nodes)
      lookahead.selection(:nodes).selections
    else
      lookahead.selections
    end
  end
end
