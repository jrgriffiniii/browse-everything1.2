# frozen_string_literal: true
require 'rails_helper'

describe "Providers", type: :request do
  describe '#index' do
    it "renders all providers" do
      get "/browse_everything/providers"
      expect(response).to render_template(:index)
    end
  end

  describe '#show' do
    xit "renders all providers" do
      get "/browse_everything/providers/file_system"
      expect(response).to render_template(:show)
    end
  end

  describe '#upload' do
    xit "creates a new file upload" do
      post "/browse_everything/providers/file_system/upload"
    end
  end

  describe '#browse' do
    it "renders all providers" do
      get "/browse_everything/providers/file_system/browse"
      expect(response).to render_template(:browse)
    end

    context 'when requesting a JSON response' do
      it "renders all providers" do
        get "/browse_everything/providers/file_system/browse", params: { format: :json }

        expect(response.status).to eq(200)
        expect(response.body).not_to be_empty

        json_body = JSON.parse(response.body)
        expect(json_body).not_to be_empty

        expect(json_body).to be_an(Array)
        expect(json_body.length).to eq(1)

        first_page = json_body.first
        expect(first_page.length).to eq(2)

        element = first_page.first
        expect(element).to include('children')
        element_children = element['children']
        expect(element_children.length).to eq(1)
        first = element_children.first

        root = first['root']
        expect(root['basename']).to eq('test')
        expect(root['parent']).to be_nil
        expect(root['path']).to eq('/test')

        children = first['children']
        expect(children.length).to eq(1)
        expect(children.first).to include('basename' => 'file_1.pdf')
      end
    end
  end
end
