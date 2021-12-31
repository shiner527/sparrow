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

    source_root File.expand_path('templates', __dir__)

    #
    # 复制模板文件到对应 Rails 项目中
    #
    def create_sparrow_class_file
      sparrow_file_path = ::File.join(TARGET_RELATIVE_PATH, class_path, "#{file_name}.rb")
      template 'sparrow_entity.rb.erb', sparrow_file_path
    end
  end
end
