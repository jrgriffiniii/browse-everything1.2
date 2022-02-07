# frozen_string_literal: true
require 'rails_helper'

describe BrowseEverything::UploadJob do
  subject(:upload_job) { described_class }
  let(:uri) { instance_double(BrowseEverything::URI) }
  let(:uris) do
    [
      uri
    ]
  end
  let(:upload) { instance_double(BrowseEverything::Upload) }

  before do
    allow(uri).to receive(:path)
    allow(uri).to receive(:params)
    allow(uri).to receive(:headers)
    allow(upload).to receive(:uris).and_return(uris)
    allow(upload).to receive(:save)
  end

  describe '#perform' do
    it 'downloads the file and attaches it to the model' do
      upload_job.perform(upload: upload)
    end
  end
end
