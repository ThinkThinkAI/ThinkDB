# frozen_string_literal: true

# The Table model represents a table within a data source. Each table has a name
# and a JSON schema that defines its structure. Tables belong to a DataSource
# and cannot be created or edited from the front-end.
class Table < ApplicationRecord
  belongs_to :data_source

  validates :name, presence: true, uniqueness: { scope: :data_source_id }
  validates :schema, presence: true
end
