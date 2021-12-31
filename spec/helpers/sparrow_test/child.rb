# frozen_string_literal: true

require_relative 'normal'

module SparrowTest
  #
  # 测试用例实体类。用来测试标准情况下的各种常规设定。
  #
  # @author Shiner <shiner527@hotmail.com>
  #
  class Child < Normal
    field :age, Integer
    field :used_names, String
  end
end
