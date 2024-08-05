# frozen_string_literal: true

class Query < ApplicationRecord
  belongs_to :data_source
  validates :name, presence: true
end
