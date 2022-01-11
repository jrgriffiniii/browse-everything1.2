# frozen_string_literal: true
require 'rails_helper'

describe BrowseEverything::Driver::FileSystem do
  subject(:file_system) { described_class.new(home: home) }
  let(:home) { Rails.root.join('..', '..', 'spec', 'fixtures') }

  describe '.new' do
    context 'with invalid configuration values' do
      it 'raises an error' do
        expect { described_class.new }.to raise_error(StandardError)
      end
    end
  end

  describe '#contents' do
    it 'builds a page of file entries' do
      pages = file_system.contents
      expect(pages).not_to be_empty

      page = pages.first
      expect(page).to be_a(BrowseEverything::Driver::FileSystem::Page)
      expect(page).not_to be_empty
      expect(page.length).to eq(2)

      resource_tree = page.first
      expect(resource_tree).to be_a(BrowseEverything::Driver::FileSystem::ResourceTree)

      child_tree = page[1]
      expect(child_tree).to be_a(BrowseEverything::Driver::FileSystem::ResourceTree)

      directory_upload = child_tree.root
      expect(directory_upload).to be_a(BrowseEverything::Driver::FileSystem::DirectoryUpload)

      expect(directory_upload.local_path.to_s).to eq("#{home}/test")
    end

    context 'when searching for a specific file system path' do
      it 'builds a page of file entries restricted to this path' do
        pages = file_system.contents(path: '/test')
        expect(pages).not_to be_empty
        expect(pages.length).to eq(1)
        page = pages.first
        expect(page).to be_a(BrowseEverything::Driver::FileSystem::Page)

        expect(page).not_to be_empty
        expect(page.length).to eq(2)
        file_upload = page.elements.last
        expect(file_upload).to be_a(BrowseEverything::Driver::FileSystem::FileUpload)

        local_path = File.join(home, '/test', 'file_1.pdf')
        expect(file_upload.local_path.to_s).to eq(local_path)
        path = File.join('/test', 'file_1.pdf')
        expect(file_upload.path.to_s).to eq(path)
        expect(file_upload.uri.to_s).to eq("file://#{local_path}")
      end
    end
  end
end
