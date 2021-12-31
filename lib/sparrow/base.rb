# frozen_string_literal: true

module Sparrow
  #
  # 对麻雀实体类进行基础类定义和设置通用的属性方法等。所有实际使用的实体类都要基于此类进行设置。
  #
  # @author Shiner <shiner527@hotmail.com>
  #
  class Base
    extend ::ActiveModel::Callbacks
    extend ::ActiveModel::Translation
    include ::ActiveModel::Dirty
    include ::ActivemodelObjectInfo::Base

    extend ClassMethods
    # @!parse extend ClassMethods

    # 定义初始化方法的回调支持
    define_model_callbacks :initialize

    #
    # 初始化基本实体类。
    #
    # @param [Hash] attribute_settings 一个包含字段名称和对应值的散列。
    #
    def initialize(**attribute_settings)
      run_callbacks(:initialize) do
        attribute_settings.each do |key, value|
          # puts "key=#{key}, value=#{value}, respond=#{respond_to?(key.to_s + '=')}"
          __send__("#{key}=", value) if respond_to?("#{key}=")
        end
        true # 这里必须保证为true让block值为真，确保回调会被调用
      end
    end

    #
    # 获取当前实例中通过类设定属性的键值对，键名为属性名，值为对应属性的值。
    #
    # @return [Hash] 返回对应的属性名和属性值的键值对。
    #
    def attributes
      attribute_names.index_with { |attribute_name| __send__(attribute_name) }
    end

    #
    # 获取当前实例中通过类方法 {Sparrow::ClassMethods#define_object_attribute} 设定的属性。
    #
    # @return [Array<Symbol>] 返回一个数组，每个元素均为当前实例对应的类中设定的属性名。
    #
    def attribute_names
      self.class.attribute_keys.compact_blank.map(&:to_sym)
    end

    #
    # 提供实例中快速获取 I18n 文本的方法。会根据当前类自动选择路径查找。详情参照对应同名类方法。
    #
    # @param [Symbol, String] name 对应 I18n 文件中的最终名称。
    # @param [Symbol, String] type 可选的。对应 I18n 文件中该名称所属的上一级命名空间，默认为 +:label+ 值。
    # @param [String, Symbol] scope 可选的。对应 I18n 文件中上一级命名空间之前，sparrow 命名空间之下的所有命名空间。
    #  每个命名空间之间用半角符号 +.+ 隔开。没有给出则默认使用当前类以及类的命名空间作为路径。
    # @param [Hash] options 可选的。其他参数。主要用来设定模板文字中的变量使用。
    #
    # @return [String] 返回对应的字符串。
    #
    def i18n(name, type: :label, scope: nil, options: {})
      self.class.i18n(name, type: type, scope: scope, options: options)
    end
  end
end
