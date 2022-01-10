# frozen_string_literal: true

RSpec.describe ::SparrowTest::Normal do
  # 测试当前版本等内容
  describe 'current gem' do
    it 'current version' do
      expect(::Sparrow::VERSION).to eq('0.1.4')
    end
  end

  # 测试新建实例
  describe '.new' do
    context 'with initialize callback' do
      it 'before and after intialize' do
        obj = described_class.new
        expect(obj.id).to eq(-999)
        expect(obj.first_name).to eq('三')
        expect(obj.last_name).to eq('张')
      end

      it 'intialize callback run but is skipped' do
        obj = described_class.new(id: 123, first_name: '四', last_name: '李')
        expect(obj.id).to eq(123)
        expect(obj.first_name).to eq('四')
        expect(obj.last_name).to eq('李')
      end
    end

    context 'with value which is not defined' do
      it 'give undefined value' do
        obj = described_class.new(id: 123, type: 456)
        expect(obj.id).to eq(123)
        expect(obj).to_not respond_to(:type)
      end
    end
  end

  # 测试 DSL 定义字段
  describe '.field' do
    context 'with float fields' do
      it 'test float field' do
        obj = described_class.new(weight: 66.2)
        expect(obj.weight).to eq(66.2)
      end

      it 'test cast type' do
        obj = described_class.new(weight: '100')
        expect(obj.weight).to eq(100.0)
      end
    end

    context 'with array field' do
      it 'correct type value' do
        obj = described_class.new(used_names: %w[李四 王五 赵六])
        expect(obj.used_names).to eq(%w[李四 王五 赵六])
      end

      it 'parse from string' do
        obj = described_class.new(used_names: '["李四","王五","赵六"]')
        expect(obj.used_names).to eq(%w[李四 王五 赵六])
      end

      it 'with invalid type' do
        obj = described_class.new(used_names: 10000)
        expect(obj.used_names).to eq([])
        expect { described_class.new(used_names: 'not valid string can be parsed') }.to raise_error(::JSON::ParserError)
      end
    end

    context 'with datetime field' do
      it 'correct type' do
        obj = described_class.new(updated_at: DateTime.now)
        expect(obj.updated_at).to be_instance_of(DateTime)
        expect(obj.updated_at).to_not eq(described_class::DEFAULT_TIMESTAMP)
      end

      it 'parse from string' do
        obj = described_class.new(updated_at: '1999-12-31')
        expect(obj.updated_at).to be_instance_of(DateTime)
        expect(obj.updated_at.year).to eq(1999)
        expect(obj.updated_at.month).to eq(12)
        expect(obj.updated_at.day).to eq(31)
      end

      it 'invalid type' do
        obj = described_class.new(updated_at: :invalid)
        expect(obj.updated_at).to eq(described_class::DEFAULT_TIMESTAMP)
      end
    end

    context 'with boolean field' do
      it 'true value' do
        obj = described_class.new(married: true)
        expect(obj.married).to eq(true)
      end

      it 'false value' do
        obj = described_class.new(married: false)
        expect(obj.married).to eq(false)
      end

      it 'without value' do
        obj = described_class.new
        expect(obj.married).to eq(nil)
      end

      it 'other type value as true' do
        obj = described_class.new(married: 'yes')
        expect(obj.married).to eq(true)
      end

      it 'other type value as false' do
        obj = described_class.new(married: '')
        expect(obj.married).to eq(false)
      end
    end
  end

  # 测试属性键值对
  describe '#attributes' do
    it 'get all attributes' do
      obj = described_class.new
      attributes = obj.attributes
      expect(attributes).to be_instance_of(::Hash)
      expect(attributes).to a_hash_including({
                                               id: eq(-999),
                                               first_name: eq('三'),
                                               last_name: eq('张'),
                                               used_names: eq([]),
                                               married: eq(nil),
                                               created_at: eq(DateTime.parse('2022-01-01')),
                                               updated_at: eq(DateTime.parse('2022-01-01')),
                                             })
    end
  end

  # 测试I18n效果
  describe '#i18n' do
    it 'first_name label' do
      obj = described_class.new
      expect(obj.i18n(:first_name)).to eq('名')
    end

    it 'last_name label' do
      obj = described_class.new
      expect { obj.i18n(:last_name) }.to raise_error do |error|
        expect(error).to be_instance_of(::I18n::MissingTranslationData)
        expect(error.message).to eq('translation missing: zh-CN.sparrow.base.label.last_name')
      end
    end

    it 'use base label' do
      obj = described_class.new
      expect(obj.i18n(:invalid_label)).to eq('无效的内容')
    end
  end
end
