require 'spec_helper'

describe Spree::FavoritesController do

  shared_examples_for "request which finds favorite product" do
    it "finds favorite product" do
      @favorites.should_receive(:find).with('id')
      send_request
    end

    it "assigns @favorite" do
      send_request
      assigns(:favorite).should eq(@favorite)
    end
  end

  describe 'POST create' do

    context 'when invalid' do
      it 'fails' do
        # TODO remove this when testing non logged in users
        @user = double(Spree::User, :favorites => Spree::Favorite, :generate_spree_api_key! => false, :last_incomplete_spree_order => nil)
        controller.stub(:spree_current_user).and_return(@user)

        post :create, :id => 1, :format => :js, :type => 'Spree::Order', :use_route => 'spree'
        assigns(:message).should match("Favorable type is not included in the list")
      end
    end

    context 'when valid' do
      def send_request
        post :create, :favorable_id => 1, :format => :js, :favorable_type => 'Spree::Product', :use_route => 'spree'
      end

      before(:each) do
        @favorite = double(Spree::Favorite, :save => true)
        controller.stub(:authenticate_spree_user!).and_return(true)
        Spree::Favorite.stub(:new).and_return(@favorite)
        @user = double(Spree::User, :favorites => Spree::Favorite, :generate_spree_api_key! => false, :last_incomplete_spree_order => nil)
        controller.stub(:spree_current_user).and_return(@user)
      end

      it "creates favorite" do
        Spree::Favorite.should_receive(:new).with(favorable_id: 1, favorable_type: 'Spree::Product')
        send_request
      end

      it "saves favorite" do
        @favorite.should_receive(:save)
        send_request
      end

      context "when favorite saved successfully" do
        it "renders create" do
          send_request
          response.should render_template(:create)
        end

        it "should assign success message" do
          send_request
          assigns(:message).should eq("Successfully added favorite.")
        end
      end

      context "when favorite not saved sucessfully" do
        before(:each) do
          @favorite.stub(:save).and_return(false)
          @favorite.stub_chain(:errors, :full_messages).and_return(["Already added as favorite."])
        end

        it "renders create template" do
          send_request
          response.should render_template(:create)
        end

        it "should assign error message" do
          send_request
          assigns(:message).should eq("Already added as favorite.")
        end
      end
    end
  end

  describe 'GET index' do
    def send_request
      get :index, :page => 'current_page', :use_route => 'spree'
    end

    before(:each) do
      @favorites = double('favorites')
      @favorites.stub(:page).and_return(@favorites)
      @favorites.stub(:per).and_return(@favorites)
      Spree::Config.stub(:favorites_per_page).and_return('favorites_per_page')
      @user = double(Spree::User, :favorites => @favorites, :generate_spree_api_key! => false, :last_incomplete_spree_order => nil)
      controller.stub(:spree_current_user).and_return(@user)
    end

    it "finds favorite products of current user" do
      @user.should_receive(:favorites)
      send_request
    end

    it "paginates favorite products" do
      @favorites.should_receive(:page).with('current_page')
      send_request
    end

    it "shows Spree::Config.favorites_per_page" do
      @favorites.should_receive(:per).with('favorites_per_page')
      send_request
    end

    it "assigns @favorite_products" do
      send_request
      assigns(:favorites).should eq(@favorites)
    end
  end

  describe 'destroy' do
    def send_request(params = {})
      post :destroy, params.merge({:use_route => 'spree', :method => :delete, :format => :js, :id => 'id'})
    end

    before do
      @favorite = double(Spree::Favorite, destroy: true, favorable_id: 1, favorable_type: 'Spree::Product')
      @favorites = double('spree_favorites')
      @favorites.stub(:find).and_return(@favorite)
      @user = double(Spree::User, :favorites => @favorites, :generate_spree_api_key! => false, :last_incomplete_spree_order => nil)
      controller.stub(:spree_current_user).and_return(@user)
    end

    it_behaves_like "request which finds favorite product"

    context 'when @favorite  exist' do
      before(:each) do
        controller.instance_variable_set(:@favorite, @favorite)
      end

      it 'destroys' do
        @favorite.should_receive(:destroy)
        send_request
      end

      context 'when destroyed successfully' do
        before(:each) do
          @favorite.stub(:destroy).and_return(true)
        end

        it "sets @success to true" do
          send_request
          assigns(:success).should eq(true)
        end
      end

      context 'when not destroyed' do
        before(:each) do
          @favorite.stub(:destroy).and_return(false)
        end

        it 'sets @success to false' do
          send_request
          assigns(:success).should eq(false)
        end
      end
    end

  end
end
