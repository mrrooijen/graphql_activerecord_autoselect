# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "simplecov"
SimpleCov.start

require "minitest/autorun"
require "graphql_activerecord_autoselect"

module TestHelpers
  module ClassMethods
    def test(name, &block)
      definition = "test_" + name.downcase.gsub(" ", "_")

      define_method(definition) do
        instance_eval(block)
      end
    end
  end
end

class CreateAModel < ActiveRecord::Migration[5.0]
  def change
    create_table :a_models do |t|
      t.string :first_name
      t.string :last_name
    end
  end
end

class CreateBModel < ActiveRecord::Migration[5.0]
  def change
    create_table :b_models do |t|
      t.string :first_name
      t.string :last_name
      t.string :type
      t.string :parent_id
      t.string :parent_type
    end
  end
end

class CreateCModel < ActiveRecord::Migration[5.0]
  def change
    create_table :c_models do |t|
      t.string :first_name
    end
  end
end

class CreateDModel < ActiveRecord::Migration[5.0]
  def change
    create_table :d_models do |t|
      t.string :first_name
      t.string :last_name
      t.references :b_model
    end
  end
end

ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => ":memory:",
)

CreateAModel.migrate(:up)
CreateBModel.migrate(:up)
CreateCModel.migrate(:up)
CreateDModel.migrate(:up)

class AModel < ActiveRecord::Base
end

class BModel < ActiveRecord::Base
  has_many :d_models
end

class CModel < ActiveRecord::Base
end

class DModel < ActiveRecord::Base
  belongs_to :b_model
end
