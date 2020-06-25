# frozen_string_literal: true

require 'rails_helper'

describe User::Operation::Create do
  subject(:operation) { User::Operation::Create.call(params: params)  }
  context '渡されるパラメーターが正しい' do
    let(:params) {  { user: { email: 'validformat@gmail.com', uid: 'Ai9W22C2Rdb6vHcS7RWhxsSsZKr2' }} }
    it 'operationが成功する' do
      expect(subject.success?).to be_truthy
      expect(subject["model"].persisted?).to be_truthy
      expect(subject["model"].calendars.first.persisted?).to be_truthy
    end
  end
end
