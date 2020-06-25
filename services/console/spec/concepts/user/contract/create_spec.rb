# frozen_string_literal: true

require 'rails_helper'

describe User::Contract::Create do
  let(:contract) { User::Contract::Create.new(user) }
  let(:user) { User.new }

  context 'パラメータとして渡される属性が不正' do
    describe 'uid' do
      it 'uid属性が存在しない' do
        expect(contract.validate({ email: 'sample@gmail.com' })).to be_falsy
        expect(contract.errors.messages[:uid]).to include 'must be filled'
      end

      it 'uidが空文字' do
        expect(contract.validate({ email: 'sample@gmail.com', uid: '' })).to be_falsy
        expect(contract.errors.messages[:uid]).to include 'must be filled'
      end
    end

    describe 'email' do
      it 'email属性が存在しない' do
        expect(contract.validate({ uid: 'lolem ipsum' })).to be_falsy
        expect(contract.errors.messages[:email]).to include 'must be filled'
      end

      it 'emailが空文字' do
        expect(contract.validate({ email: '', uid: 'lolem ipsum' })).to be_falsy
        expect(contract.errors.messages[:email]).to include 'must be filled'
      end

      it 'emailのフォーマットが不正' do
        expect(contract.validate({ email: 'invalidformat&mail.com', uid: 'lolem ipsum' })).to be_falsy
        expect(contract.errors.messages[:email]).to include 'has invalid format'
      end
    end
  end

  context 'パラメータとして渡される属性が正しい' do
    it 'validateがtrueを返す' do
      expect(contract.validate({ email: 'validformat@gmail.com', uid: 'Ai9W22C2Rdb6vHcS7RWhxsSsZKr2' })).to be_truthy
    end
  end
end
