# frozen_string_literal: true

require 'rails_helper'

describe Shared::Representer::Errors do
  context 'resultが1つの属性についてだけエラーメッセージを持つ' do
    let(:messages) { { attr1: ["is too long"] } }

    it 'okがfalse' do
      result = double('operation result')
      expect(result).to receive(:success?).and_return(false)
      expect(result).to receive_message_chain("[].errors.messages").and_return(messages)

      serializable_hash = Shared::Representer::Errors.represent(result, serializable: true)
      expect(serializable_hash[:ok]).to be_falsy
    end

    it 'errorsに期待通りのメッセージが含まれる' do
      result = double('operation result')
      expect(result).to receive(:success?).and_return(false)
      expect(result).to receive_message_chain("[].errors.messages").and_return(messages)

      serializable_hash = Shared::Representer::Errors.represent(result, serializable: true)
      expect(serializable_hash[:errors]).to include("attr1 is too long")
    end
  end

  context 'resultが1つの属性について複数のエラーメッセージを持つ' do
    let(:messages) { { attr1: ['is too long', 'is invalid format'] } }

    it 'errorsに期待通りのメッセージが含まれる' do
      result = double('operation result')
      expect(result).to receive(:success?).and_return(false)
      expect(result).to receive_message_chain("[].errors.messages").and_return(messages)

      serializable_hash = Shared::Representer::Errors.represent(result, serializable: true)
      expect(serializable_hash[:errors]).to include("attr1 is too long")
      expect(serializable_hash[:errors]).to include("attr1 is invalid format")
    end
  end

  context 'resultが複数の属性について複数のエラーメッセージを持つ' do
    let(:messages) { { attr1: ['is too long', 'is invalid format'], attr2: ['must be filled'] } }

    it 'errorsに期待通りのメッセージが含まれる' do
      result = double('operation result')
      expect(result).to receive(:success?).and_return(false)
      expect(result).to receive_message_chain("[].errors.messages").and_return(messages)

      serializable_hash = Shared::Representer::Errors.represent(result, serializable: true)
      expect(serializable_hash[:errors]).to include("attr1 is too long")
      expect(serializable_hash[:errors]).to include("attr1 is invalid format")
      expect(serializable_hash[:errors]).to include("attr2 must be filled")
    end
  end
end
