# frozen_string_literal: true

module SparrowTest
  #
  # 测试用例实体类。用来测试标准情况下的各种常规设定。
  #
  # @author Shiner <shiner527@hotmail.com>
  #
  class Normal < Sparrow::Base
    DEFAULT_TIMESTAMP = DateTime.new(2022, 1, 1)

    field :id, Integer
    field :first_name, String
    field :last_name, String
    field :used_names, Array, default: []
    fields DateTime, :created_at, :updated_at, default: DEFAULT_TIMESTAMP

    field :weight, Float

    field :married, ::Sparrow::Boolean

    before_initialize :call_before_initialize
    after_initialize :call_after_initialize

    def call_before_initialize
      self.id = -999 if id.blank?
    end

    def call_after_initialize
      self.first_name = '三' if first_name.blank?
      self.last_name = '张' if last_name.blank?
    end
  end
end
