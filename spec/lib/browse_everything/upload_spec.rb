# frozen_string_literal: true
require 'rails_helper'

describe BrowseEverything::Upload do
  subject(:upload) { described_class.new(requests: requests) }

  let(:uris) do
    [
      'file://file.txt',
      'https://host.domain/file.txt'
    ]
  end
  let(:request1) { BrowseEverything::Request.new(uri: uris.first) }
  let(:request2) { BrowseEverything::Request.new(uri: uris.last) }
  let(:requests) do
    [
      request1,
      request2
    ]
  end

  describe '#requests' do
    it 'accesses the URIs for the requested resources' do
      expect(upload.requests.length).to eq(2)

      expect(upload.requests.first).to be_a(BrowseEverything::Request)
      expect(upload.requests.first.uri.scheme).to eq('file')

      expect(upload.requests.last).to be_a(BrowseEverything::Request)
      expect(upload.requests.last.uri.scheme).to eq('https')
    end
  end

  describe '#job' do
    it 'accesses the UploadJob for the Upload' do
      expect(upload.job).to be(BrowseEverything::UploadJob)
    end
  end
end
