# frozen_string_literal: true

require 'rails_helper'

describe User::Representer::Create do
  context 'operationが成功した場合' do
    it 'okがtrue' do
      result = double('operation result')
      expect(result).to receive(:success?).and_return(true)

      serializable_hash = User::Representer::Create.represent(result, serializable: true)
      expect(serializable_hash[:ok]).to be_truthy
    end
  end
end
