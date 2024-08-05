# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TablesController, type: :controller do
  let(:data_source) { create(:data_source) }
  let(:table) { create(:table, data_source:) }

  describe 'GET #show' do
    context 'when the data_source and table exist' do
      before do
        get :show, params: { data_source_id: data_source.id, id: table.id }
      end

      it 'assigns the requested data_source to @data_source' do
        expect(assigns(:data_source)).to eq(data_source)
      end

      it 'assigns the requested table to @table' do
        expect(assigns(:table)).to eq(table)
      end

      it 'renders the show template' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the table as json' do
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(table.id)
      end
    end

    context 'when the data_source does not exist' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect do
          get :show, params: { data_source_id: 9999, id: table.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the table does not exist' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect do
          get :show, params: { data_source_id: data_source.id, id: 9999 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
