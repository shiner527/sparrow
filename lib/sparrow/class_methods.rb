# frozen_string_literal: true

module Sparrow
  #
  # 基础通用非数据表对应类型的类方法设定。
  #
  module ClassMethods
    # 默认的主键名称
    DEFAULT_PRIMARY_KEY_NAME = 'id'

    # @!attribute [r] primary_key
    #   当前实体类的主键属性名。
    #   @return [Symbol] 主键属性名称。
    attr_reader :primary_key

    #
    # 当前实体类所有的字段名。为一个数组，每个元素为一个符号，代表一个属性的名称。
    # 属性包含了在当前实体类定义的属性以及继承自父类的属性。如果是多层继承，会依次获取各级父类的属性。
    #
    # @return [Array<Symbol>] 返回实体类所有字段属性名。
    #
    def attribute_keys
      # 获取本体的属性，如果为 nil 则赋值为空数组
      attr_keys_val = instance_variable_get('@attribute_keys')
      attr_keys_val = instance_variable_set('@attribute_keys', []) if attr_keys_val.nil?
      # 获取继承类的属性，直到本类为止
      acs = ancestors.dup
      acs.shift
      attr_keys_val = [acs.first.attribute_keys, attr_keys_val].flatten.uniq if acs.include?(::Sparrow::Base) && acs.first != ::Sparrow::Base
      # 返回最终结果
      attr_keys_val
    end

    #
    # 为当前类定义一个属性，这个属性包括获取方法和设置方法，并且根据定义的属性类型会在设置时自动转化为对应的数据。
    #
    # @param [Symbol, String] attr_name 属性名称。
    # @param [Class] attr_class 属性的类型。可以是 *Integer* 整形数；<b>Float</b> 浮点型数；
    #  <b>Time DateTime Date</b> 三种时间日期类型，或者其他类型。
    # @param [Hash] options 额外的可选设置。
    # @option options [Boolean] :primary_key 作为主键属性的名称。默认为 +true+ 的字段。
    # @option options [Object] :default 默认值。如果设定了该可选项，且获取到的结果为空时，则一定返回默认值。
    #  因此设定后之后故意赋值为 nil 则不起作用，除非默认值也是 nil 或者不设定默认值。
    #
    def define_object_attribute(attr_name, attr_class, **options)
      # 设置获取方法名称和设置方法名称
      getter_name = attr_name.to_s
      setter_name = "#{attr_name}="
      instance_var_name = "@#{attr_name}"

      # 设置主键属性，当可选项 primary_key 被设置为 true 或者当前还没有主键且当前属性名为 'id' 时会被设置为主键
      @primary_key = getter_name if options[:primary_key] || (primary_key.blank? && getter_name == DEFAULT_PRIMARY_KEY_NAME)

      # 定义读取方法
      define_method(getter_name) do
        val = instance_variable_get(instance_var_name)
        # 当设定了默认值且获取到的值为 nil 时使用默认值。
        # 调试时输出用 "class: #{self}, getter_name: #{getter_name}, options: #{options}"
        val = options[:default] if options.key?(:default) && val.nil?
        val
      end

      # 根据类别定义赋值方法
      if attr_class == ::Integer
        # 如果是整形数，设置时进行转化
        define_method(setter_name) do |value|
          instance_variable_set(instance_var_name, value.to_i)
        end
      elsif attr_class == ::Float
        # 如果是浮点数，设置时进行转化
        define_method(setter_name) do |value|
          instance_variable_set(instance_var_name, value.to_f)
        end
      elsif [::Date, ::DateTime, ::Time].include?(attr_class)
        # 如果是时间或者日期类型，设置时进行转化
        define_method(setter_name) do |value|
          val = nil
          case value
          when ::Date, ::DateTime, ::Time
            val = value
          when ::String
            val = attr_class.parse(value)
          end
          instance_variable_set(instance_var_name, val)
        end
      elsif [::Hash, ::Array].include?(attr_class)
        # 如果是散列或者数组的时候，要分别处理
        define_method(setter_name) do |value|
          val = case value
                when attr_class
                  value
                when ::String
                  # begin
                  ::JSON.parse(value)
                  # rescue ::StandardError
                  #   attr_class.new
                  # end
                end
          instance_variable_set(instance_var_name, val)
        end
      elsif attr_class == ::Sparrow::Boolean
        # 如果是布尔值类型
        define_method(setter_name) do |value|
          instance_variable_set(instance_var_name, value.present?)
        end
      else
        # 其他类型原封不动
        define_method(setter_name) do |value|
          instance_variable_set(instance_var_name, value)
        end
      end

      # 将定义好的属性记录当当前属性列表中
      if @attribute_keys.blank?
        @attribute_keys = [attr_name]
      else
        @attribute_keys << attr_name
      end
    end
    alias field define_object_attribute

    #
    # 定义多个同类型的属性。每一个单体定义都可参考 {#define_object_attribute} 方法。
    #
    # @param [Class] attrs_class 属性的类型。
    # @param [Array] args 多个属性的名称数组。
    # @param [Hash] options 额外的可选设置。
    #
    def define_object_attributes(attrs_class, *args, **options)
      # puts "args, type and options: args => #{args.inspect}, type => #{attrs_class.inspect}, options => #{options.inspect}"
      args.each { |attr_name| define_object_attribute(attr_name, attrs_class, **options) }
    end
    alias fields define_object_attributes

    #
    # 快速获取 I18n 文本的方法。会根据当前类自动选择路径查找。
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
      path = scope || to_s.underscore.split('/').compact_blank.join('.')
      current_key = "sparrow.#{path}.#{type}.#{name}"
      default_key = "sparrow.base.#{type}.#{name}"
      ::I18n.exists?(current_key) ? ::I18n.t!(current_key, options) : ::I18n.t!(default_key, options)
    end
  end
end
