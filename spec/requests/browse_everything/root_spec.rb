# frozen_string_literal: true
require 'rails_helper'

describe "application root page", type: :request do
  it "renders all providers" do
    get "/browse_everything"
    expect(response).to render_template(:index)
  end
end
