# frozen_string_literal: true
require 'rails_helper'

describe BrowseEverything::UploadJob do
  subject(:upload_job) { described_class }

  let(:uri) { 'https://localhost.localdomain/file.bin' }
  let(:files) { double }
  let(:request) { BrowseEverything::Request.new(uri: uri) }
  let(:requests) do
    [
      request
    ]
  end
  let(:upload) { instance_double(BrowseEverything::Upload) }

  before do
    # allow(uri).to receive(:path)
    # allow(uri).to receive(:params)
    # allow(uri).to receive(:headers)
    # allow(request).to receive(:transmit)

    allow(files).to receive(:attach)
    allow(upload).to receive(:save)
    allow(upload).to receive(:files).and_return(files)
    allow(upload).to receive(:requests).and_return(requests)

    stub_request(:get, "http://localhost.localdomain:443/file.bin").to_return(status: 200, body: "content", headers: { 'Content-Type': 'application/octet-stream' })
  end

  describe '#perform' do
    before do
      upload_job.perform_now(upload: upload)
    end

    it 'downloads the file and attaches it to the model' do
      expect(upload).to have_received(:save)
    end
  end
end
