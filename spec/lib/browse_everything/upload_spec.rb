# frozen_string_literal: true
require 'rails_helper'

describe BrowseEverything::Upload do
  subject(:upload) { described_class.new(uris: uris) }
  let(:uris) do
    [
      'file://file.txt',
      'https://host.domain/file.txt'
    ]
  end

  describe '#uris' do
    it 'accesses the URIs for the requested resources' do
      expect(upload.uris.length).to eq(2)

      expect(upload.uris.first).to be_a(URI::File)
      expect(upload.uris.first.to_s).to eq('file://file.txt')
      expect(upload.uris.last).to be_a(URI::HTTPS)
      expect(upload.uris.last.to_s).to eq('https://host.domain/file.txt')
    end
  end

  describe '#job' do
    it 'accesses the UploadJob for the Upload' do
      expect(upload.job).to be(BrowseEverything::UploadJob)
    end
  end
end
