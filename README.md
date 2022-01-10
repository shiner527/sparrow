# Sparrow

Sparrow 用来快速实现在一个 Ruby 项目中引入实体处理非数据库可以映射的项目。特别是对于拆分为微服务的项目来说，由于大量数据基于其他服务获取到，而并不是直接来源于数据库，所以不能使用基于 **ActiveRecord::Base** 这样的类来处理具体数据实例。而 Sparrow 就提供了类似 ORM 式的使用方法来处理这些对象类。

## 安装

在你的项目中的 Gemfile 文件添加如下一行即可。建议保持最新版本以获取功能齐全的体验。

```ruby
gem 'sparrow-entity', require: 'sparrow'
```

之后在你的项目文件夹下执行命令安装。

  $ bundle

或者也可以直接使用 gem 命令全局安装。

  $ gem install sparrow-entity

## 使用

### 一般的使用方法

安装之后尽可以在需要的时候随意创建自己的实体类，只要继承该 gem 提供的基础类即可。需要注意的是，如果你是在单纯的 Ruby 项目下使用，记得在使用前引入相关文件，比如：

```ruby
# 使用本 gem 引入。如果是 Rails 项目则可省略。
require 'sparrow'

# 定义一个继承自 gem 基本实体类的自定义实体类
class MyEntity < Sparrow::Base
  # 定义相关的属性和类型
  field :id, Integer
  field :family_name, String
  field :given_name, String
  field :gender, Integer
  field :birthday, Date
  field :nationality, String
  # 也可以给与属性默认值，如果属性值本身无效时获取该属性会返回默认值
  field :status, String, default: 'good'

  # 定义具体的实例方法可以在之后使用
  def full_name(last: :given, seperator: ' ')
    val = [family_name, given_name]
    val.reverse! if last == :family
    val.join(seperator)
  end
end
```

这样定义的一个类就具有了唯一标示 **id**，姓氏 **family_name**，名字 **given_name**，性别 **gender**，出生日期 **birthday** 和国籍 **nationality** 这几个属性，并且会在赋值和获取对应属性值时尝试自动将该属性设置转换为对应的数据类型。举例来说，比如给出一个可以被解析的日期字符串并赋值给出生日期属性，那么获取该属性值时会自动转化成定义属性时设定的 **Date** 类型的日期：

```ruby
me = MyEntity.new(birthday: '2022-01-01')
me.birthday
# => <Date 2022年1月1日> 实例对象
```

### 布尔型属性

当需要定义一个属性字段为布尔型时，可以使用本 gem 内置的 `Sparrow::Boolean` 作为类型定义即可。当赋予 **true** 值或者等价于（即使用 `present?` 判断为真）其值时被赋予真值，否则被赋予假值。同样的，如果没有对其进行赋值，则获取该字段属性会返回 **nil** 空值。

```ruby
class OtherEntity < Sparrow::Base
  field :married, Sparrow::Boolean
end

obj = OtherEntity.new
obj.married
# => nil

obj.married = true
obj.married
# => true

obj.married = ''
obj.married
# => false

obj.married = 'yes'
obj.married
# => true
```

### 赋值

上例中也展示了为实体类的实例进行属性赋值的方式之一，即创建时指定属性名对应的值。当然也可以在创建后分别给属性赋值。

```ruby
me.family_name = '张'
me.last_name = '三'
me.full_name(seperator: '')
# => "张三" 
```

### 默认属性值

在定义属性的时候可以跟着 `default` 命名参数给出默认值。当属性值为空或者无效时，获取属性的时候会返回默认值。

```ruby
me.status
# => "good"
me.status = 'bad'
me.status
# => "bad"
```

### 基于 Rails 项目的使用方法

如果你的项目是一个基于 Rails 框架的项目，那么在创建自己的实体时并不需要特别声明引入该 gem 对应的文件，因为 Rails 框架已经替你做好了一切。

另外，使用 Rails 框架的项目还可以利用本 gem 提供的生成器(Generator)来方便快速生成一个新的实体类。

  $ rails g sparrow:entity Post::Replay

使用命令 Rails 生成器命令 `sparrow:entity` 会在你的项目根文件夹的 `app/entities` 路径下生成 `post/reply.rb` 的文件，文件也自动创建了好了继承类。

```ruby
module Post
  class Reply < Sparrow::Base
  end
end
```

之后可以根据自己的需要修改生成的框架类的命名空间或者类的名称。

### 内置的属性方法

除了常规的 `attributes` 和 `attribute_names` 方法分别获取属性名和值的键值对以及属性名的数组外，本 gem 还内置了 [activemodel_object_info](https://rubygems.org/gems/activemodel_object_info) 这个 gem 辅助生成属性和值的键值对散列。具体用法请参考相关 gem 的说明文档。

```ruby
OUTPUT = { 
  attributes: [
    { name: :full_name, type: :method },
    { name: :sex, as: :gender, type: :abstract, filter: ->(v) { v == 1 ? 'Male' : 'Female' } },
  ],
}.freeze

me.instance_info(OUTPUT)
# => { full_name: "张三", sex: "Male" }
```

## 面向开发者

内置 Rake 命令包括了控制台开启命令 `rake c` 或者 `rake console` 即可开启控制台模式。

默认的 Rake 命令为单元测试命令，等同于 `bundle exec rspec` 命令的效果。

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
