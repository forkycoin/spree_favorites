module Spree
  module Admin
    class FavoritesController < Spree::Admin::BaseController

      def index
        @favorites = Spree::Product.favorite
      end

      def users
        @product = Spree::Product.where(:id => params[:id]).first
        @users = @product.favorite_users
      end
    end
  end
end
