# frozen_string_literal: true
require 'rails_helper'

describe BrowseEverything do
  describe '::VERSION' do
    it 'accesses the current version of the Gem' do
      expect(described_class::VERSION).to eq('1.2.0')
    end
  end
end
