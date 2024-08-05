# frozen_string_literal: true

class Query < ApplicationRecord
  belongs_to :data_source
  validates :name, presence: true, uniqueness: { scope: :data_source_id }
end
