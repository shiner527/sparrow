# frozen_string_literal: true

module Sparrow
  #
  # 创建一个自定义的创建 Sparrow::Base 的类。
  #
  # @author Shiner <shiner527@hotmail.com>
  #
  class EntityGenerator < Rails::Generators::NamedBase
    # 默认的引入应用的相对安装路径
    TARGET_RELATIVE_PATH = 'app/entities'

    # 单模组模板
    MODULE_TEMPLATE = <<~MODULE.strip
      module %{module_name}
      %{module_content}
      end
    MODULE

    # 单类模板
    CLASS_TEMPLATE = <<~KLASS.strip
      class %{class_name} < Sparrow::Base
        #
        # Useage:
        #
        # use field DSL to define attribute.
        # like: <tt>field :name, String</tt> to define an string attribute called +name+.
        #
      end
    KLASS

    source_root File.expand_path('templates', __dir__)

    #
    # 复制模板文件到对应 Rails 项目中
    #
    def create_sparrow_class_file
      # 如果存在命名空间，则分别生成对应模型
      if class_path.present?
        class_path.each_with_index do |sub, index|
          @sub_paths = class_path[0..index]
          parent_paths = @sub_paths.dup
          parent_paths.pop
          sub_path = ::File.join(TARGET_RELATIVE_PATH, parent_paths, "#{sub}.rb")
          template 'module.rb.tt', sub_path
        end
      end

      # 类文件最终路径
      sparrow_file_path = ::File.join(TARGET_RELATIVE_PATH, class_path, "#{file_name}.rb")
      # 类文件生成
      template 'sparrow_entity.rb.tt', sparrow_file_path
    end

    private

    def indent_level
      @indent_level = @indent_level.blank? ? 0 : @indent_level + 1
    end

    def __module_content__(name, content)
      MODULE_TEMPLATE % { module_name: name.camelize, module_content: indent(content, 2) }
    end

    def __class_content__
      CLASS_TEMPLATE % { class_name: file_name.camelize }
    end

    def __class_body__
      results = __class_content__
      class_path.reverse.each { |sub| results = __module_content__(sub, results) } if class_path.present?
      results << "\n"
      results
    end

    def __module_body__(paths = [])
      current = paths.shift
      content = paths.size.positive? ? __module_body__(paths) : ''
      result = current ? __module_content__(current, content) : ''
      result = result.each_line.select(&:present?).join
      result << "\n"
      result
    end
  end
end
