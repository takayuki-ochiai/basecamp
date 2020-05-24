require 'rails_helper'

RSpec.describe "API::V1::Users", type: :request do
  include Committee::Rails::Test::Methods

  def committee_options
    @committee_options ||= { schema_path: Rails.root.join('openapi', 'v1', 'schema.yaml').to_s }
  end

  describe "POST /api/v1/users",  type: :request do
    it "レスポンスがAPIドキュメントと一致する" do
      post '/api/v1/users', params: { user: { uid: 'hige', email: 'ochiai@gmail.com' }}
      # expect(1).to eq 1
      assert_schema_conform
    end
  end
end
