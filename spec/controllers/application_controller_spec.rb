# spec/controllers/application_controller_spec.rb

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'OK'
    end
  end

  let(:user) { create(:user) }
  let(:data_source) { create(:data_source, user:) }

  before do
    routes.draw { get 'index' => 'anonymous#index' }
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'before_action :check_requirements' do
    context 'when user settings are incomplete' do
      it 'redirects to user settings path' do
        allow(user).to receive(:settings_incomplete?).and_return(true)
        get :index
        expect(response).to redirect_to(user_settings_path)
        expect(flash[:alert]).to eq('Please complete your settings.')
      end
    end

    context 'when user has no data sources' do
      before do
        allow(user).to receive(:data_sources).and_return(DataSource.none)
      end

      it 'redirects to new data source path' do
        get :index
        expect(response).to redirect_to(new_data_source_path)
        expect(flash[:alert]).to eq('Please create a data source.')
      end
    end

    context 'when user has inactive data sources' do
      before do
        allow(DataSource).to receive(:active).and_return(DataSource.none)
      end

      it 'connects the first data source if connection is successful' do
        allow(DatabaseService).to receive(:test_connection).with(data_source).and_return(true)
        get :index
        expect(data_source.reload.connected).to be(true)
      end

      it 'redirects to edit data source path if connection fails' do
        allow(DatabaseService).to receive(:test_connection).with(data_source).and_return(false)
        get :index
        expect(response).to redirect_to(edit_data_source_path(data_source))
        expect(flash[:alert]).to eq('Failed to connect to the DataSource. Please check your configuration.')
      end

      it 'redirects to edit data source path if connection fails' do
        allow(DatabaseService).to receive(:test_connection).with(data_source).and_return(false)
        get :index
        expect(response).to redirect_to(edit_data_source_path(data_source))
        expect(flash[:alert]).to eq('Failed to connect to the DataSource. Please check your configuration.')
      end
    end

    context 'when user doesn\'t have any data sources' do
      before do
        allow(user).to receive(:data_sources).and_return(DataSource.none)
      end

      it 'redirects to new data source path' do
        get :index
        expect(response).to redirect_to(new_data_source_path)
        expect(flash[:alert]).to eq('Please create a data source.')
      end
    end
  end
end
