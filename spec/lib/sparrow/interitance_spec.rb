# frozen_string_literal: true

RSpec.describe ::SparrowTest::Child do
  # 测试继承field性能
  describe '.field' do
    it 'new attribute' do
      obj = described_class.new(age: 24)
      expect(obj.first_name).to eq('三')
      expect(obj.id).to eq(-999)
      expect(obj.age).to eq(24)
    end

    it 'override attribute' do
      obj = described_class.new(id: 100, used_names: '李四')
      expect(obj.id).to eq(100)
      expect(obj.used_names).to eq('李四')
    end
  end
end
