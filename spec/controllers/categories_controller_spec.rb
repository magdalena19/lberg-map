require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  before do
    @map = create :map, :full_public
    @category = create :category, name_de: 'GermanName', name_en: 'EnglishName', map: @map 
  end

  describe 'GET #index' do
    it "returns all categories in map as json" do
      xhr :get, :index, map_token: @map.secret_token

      expectation = { 'name_en' => 'EnglishName', 'name_de' => 'GermanName', 'categoryId' => @category.id, 'poiCount' => 0 }
      expect(JSON.parse(response.body).first).to include expectation
    end
  end

  describe 'POST #create' do
    it 'creates category for map' do
      expect do
        xhr :post, :create, category: { name_en: 'SomeEnglishName', name_de: 'SomeGermanName' }, map_token: @map.secret_token
      end.to change { Category.count }.by(1)
    end

    it 'associates with correct map' do
      xhr :post, :create, category: { name_en: 'SomeEnglishName', name_de: 'SomeGermanName' }, map_token: @map.secret_token

      expect(assigns(:category).map).to eq @map
    end

    it 'cannot POST from map public token' do
      expect(post: "/#{@map.public_token}/categories").not_to be_routable
    end
  end

  describe 'PATCH #update' do
    before do
      @place = create :place, name: 'SomePlace', map: @map, categories_string: 'Playground'
      @category = @map.categories.find_by(name: 'Playground')
    end

    it 'can update categories via ajax' do
      xhr :patch, :update, id: @category.id, category: { name_en: 'Changed!' }, map_token: @map.secret_token

      expectation = { 'name_en' => 'Changed!', 'name_de' => '', 'categoryId' => @category.id, 'poiCount' => 1 }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to eq expectation
    end

    it 'updates all place category strings' do
      expect do
        xhr :patch, :update, id: @category.id, category: { name_en: 'Change' }, map_token: @map.secret_token
      end.to change { @place.reload.categories_string }.from('Playground').to('Change')
    end

    it 'cannot PATCH from map public token' do
      expect(patch: "/#{@map.public_token}/categories/#{@category.id}").not_to be_routable
    end
  end

  describe 'DELETE #destroy' do
    before do
      @place = create :place, name: 'SomePlace', map: @map, categories_string: 'Playground, Lawyer'
      @category = @map.categories.find_by(name: 'Playground')
    end

    it 'can delete categories via ajax' do
      expect do
        xhr :delete, :destroy, id: @category.id, map_token: @map.secret_token
      end.to change { Category.count }.by(-1)
    end

    it 'updates all places categories flags when successfully deleting tag' do
      xhr :delete, :destroy, id: @category.id, map_token: @map.secret_token

      expect(@place.reload.categories.first.name).to eq 'Lawyer'
      expect(@place.reload.categories_string).to eq 'Lawyer'
    end

    it 'cannot DELETE from map public token' do
      expect(delete: "/#{@map.public_token}/categories/#{@category.id}").not_to be_routable
    end
  end
end
