require 'rails_helper'

RSpec.describe TablesController, type: :controller do
  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user: user) }
  let(:table) { create(:table, data_source: data_source) }

  describe "GET #show" do
    before do
      get :show, params: { data_source_id: data_source.id, id: table.id }
    end

    context "when the table exists" do
      it "returns JSON response with 200 status" do
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to eq(table.id)
      end

      it "assigns the requested table to @table" do
        expect(assigns(:table)).to eq(table)
      end
    end

    context "when the table does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get :show, params: { data_source_id: data_source.id, id: 'non_existent_id' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "Private Methods" do
    describe "#set_data_source" do
      it "sets the @data_source variable" do
        expect(controller).to receive(:set_data_source).and_call_original
        get :show, params: { data_source_id: data_source.id, id: table.id }
        expect(assigns(:data_source)).to eq(data_source)
      end
    end

    describe "#set_table" do
      it "sets the @table variable" do
        expect(controller).to receive(:set_table).and_call_original
        get :show, params: { data_source_id: data_source.id, id: table.id }
        expect(assigns(:table)).to eq(table)
      end
    end
  end
end
