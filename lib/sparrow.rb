# frozen_string_literal: true

require 'sparrow/version'
require 'active_support'
require 'active_model'
require 'activemodel_object_info'
require 'sparrow/class_methods'
require 'sparrow/base'

#
# 实体总模组，统括所有支持基于 **ActiveModel** 的实体类的内容。
#
# @author Shiner <shiner527@hotmail.com>
#
module Sparrow
  # 加载本插件自带默认的 i18n 信息内容
  ::Dir[::File.expand_path('lib/config/locales/sparrow/*.yml')].each { |f| ::I18n.load_path << f }
end
