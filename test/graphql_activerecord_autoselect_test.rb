# frozen_string_literal: true

require "test_helper"

class GraphQLActiveRecordAutoSelectTest < ActiveSupport::TestCase
  include TestHelpers
  using GraphQLActiveRecordAutoSelect

  AutoSelect = GraphQLActiveRecordAutoSelect
  Lookahead = Struct.new(:selections) do
    def selection(_)
      self
    end

    def selects?(_)
      false
    end
  end

  test "return the selected fields" do
    lookahead = Lookahead.new([
      OpenStruct.new(name: :id),
      OpenStruct.new(name: :first_name)
    ])

    result = AutoSelect.call(
      model: AModel,
      lookahead: lookahead,
      dependents: {}
    )

    assert_equal ["id", "first_name"].sort, result.sort
  end

  test "return the mandatory fields" do
    lookahead = Lookahead.new([
      OpenStruct.new(name: :first_name)
    ])

    result = AutoSelect.call(
      model: BModel,
      lookahead: lookahead,
      dependents: {}
    )

    assert_equal ["id", "type", "parent_type", "parent_id", "first_name"].sort,
      result.sort
  end

  test "should return dependents" do
    lookahead = Lookahead.new([
      OpenStruct.new(name: :full_name)
    ])

    dependents = {
      full_name: [:first_name, :last_name]
    }

    result = AutoSelect.call(
      model: AModel,
      lookahead: lookahead,
      dependents: dependents
    )

    assert_equal ["id", "first_name", "last_name"].sort, result.sort
  end

  test "should ignore missing fields" do
    lookahead = Lookahead.new([
      OpenStruct.new(name: :id),
      OpenStruct.new(name: :first_name),
      OpenStruct.new(name: :last_name)
    ])

    result = AutoSelect.call(
      model: CModel,
      lookahead: lookahead,
      dependents: {}
    )

    assert_equal ["id", "first_name"].sort, result.sort
  end

  test "ActiveRecord::Base integration" do
    lookahead = Lookahead.new([
      OpenStruct.new(name: :id),
      OpenStruct.new(name: :full_name)
    ])

    dependents = {
      full_name: [:first_name, :last_name]
    }

    query = %(SELECT "b_models"."id", "b_models"."type", "b_models"."parent_id", ) +
      %("b_models"."parent_type", "b_models"."first_name", "b_models"."last_name" FROM "b_models")
    assert_equal query, BModel.autoselect(lookahead, dependents).to_sql
  end

  test "ActiveRecord::Relation integration" do
    lookahead = Lookahead.new([
      OpenStruct.new(name: :id),
      OpenStruct.new(name: :full_name)
    ])

    dependents = {
      full_name: [:first_name, :last_name]
    }

    b = BModel.create
    query = %(SELECT "d_models"."id", "d_models"."b_model_id", "d_models"."first_name", ) +
      %("d_models"."last_name" FROM "d_models" WHERE "d_models"."b_model_id" = #{b.id})
    assert_equal query, b.d_models.autoselect(lookahead, dependents).to_sql
  end
end
