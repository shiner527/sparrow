# frozen_string_literal: true

# 加载必要的测试用例类
Dir.glob([__dir__, 'sparrow_test/**/*.rb'].join('/')).sort.each { |test| require test }

#
# 测试用例模组。
#
# @author Shiner <shiner527@hotmail.com>
#
module SparrowTest
  # 加载本插件自带默认的 i18n 信息内容
  ::I18n.locale = :'zh-CN'
  ::Dir[::File.expand_path('spec/fixtures/locales/**/*.yml')].each { |f| ::I18n.load_path << f }
  ::I18n.reload!
end
