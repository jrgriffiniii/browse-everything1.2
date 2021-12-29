# frozen_string_literal: true
require 'rails_helper'

describe BrowseEverything::Driver::FileSystem do
  subject(:file_system) { described_class.new(home: home) }
  let(:home) { Rails.root.join('..', '..', 'spec', 'fixtures') }

  describe '.new' do
    context 'with invalid configuration values' do
      it 'raises an error' do
        expect { described_class.new }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#contents' do
    it 'builds a page of file entries' do
      pages = file_system.contents
      expect(pages).not_to be_empty
      page = pages.first
      expect(page.children.length).to eq(1)
      expect(page.children.first).to be_a(BrowseEverything::Upload::FileSystem::Directory)
      expect(page.children.first.path.to_s).to eq("#{home}/")
    end

    context 'when searching for a specific file system path' do
      it 'builds a page of file entries restricted to this path' do
        pages = file_system.contents(path: '/test')
        expect(pages).not_to be_empty
        page = pages.first
        expect(page.children.length).to eq(1)
        expect(page.children.first).to be_a(BrowseEverything::Upload::FileSystem::Directory)

        requested_path = File.join(home, '/test')
        expect(page.children.first.path.to_s).to eq(requested_path)
      end
    end
  end
end
