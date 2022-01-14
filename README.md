# GraphQL ActiveRecord AutoSelect

[![Gem Version](https://badge.fury.io/rb/graphql_activerecord_autoselect.svg)](https://badge.fury.io/rb/graphql_activerecord_autoselect)
[![Test Status](https://github.com/mrrooijen/graphql_activerecord_autoselect/workflows/Test/badge.svg)](https://github.com/mrrooijen/graphql_activerecord_autoselect/actions)

Automatic [ActiveRecord] column selection for [GraphQL (Ruby)] fields.

This library was developed for- and extracted from [HireFire].

The documentation can be found on [RubyDoc].


### Compatibility

- Ruby 2.7+
- ActiveRecord 6.0+
- GraphQL (Ruby) 1.9+


### Installation

Add the gem to your Gemfile and run `bundle`.

```ruby
gem "graphql_activerecord_autoselect", "~> 2"
```


### Example

```ruby
class Types::Actor < Types::Base::Object
  using GraphQLActiveRecordAutoSelect

  field :organizations, Types::Organization, null: false, extras: [:lookahead]

  def organizations(lookahead:)
    object.organizations.autoselect(lookahead)
  end

  field :organization, Types::Organization, null: false, extras: [:lookahead] do
    argument :id, ID, required: true
  end

  def organization(id:, lookahead:)
    object.organizations.autoselect(lookahead).find(id)
  end
end
```

In this example an actor has many organizations. We allow the client to query all of the actor's organizations, or a specific one by id. We acquire the lookahead functionality provided by GraphQL Ruby and pass it to `autoselect`.

The `autoselect` method is made available to ActiveRecord::Base at the class level, as well as to all instances of ActiveRecord::Relations, in classes where the GraphQLActiveRecordAutoSelect refinement is used (`using GraphQLActiveRecordAutoSelect`).

If you submit the following query to the server:

```
query {
  actor {
    organizations {
      name
      time_zone
    }
  }
}
```

It'll translate this:

```ruby
object.organizations.autoselect(lookahead)
```

Into this:

```ruby
object.organizations.select(:id, :actor_id, :name, :time_zone)
```

Notice that it didn't only select the `:name` and `:time_zone` fields, but `:id` and `:actor_id` as well. These kinds of identifiers are always selected in order to avoid potential lookup issues on other relations where they're mandatory.

The following fields are always selected:

* The primary key field (typically id)
* The type field
* Fields that end in _id
* Fields that end in _type

The example above builds a select on a has many relation, but the same works for belongs to.

```ruby
class Types::Organization < Types::Base::Object
  using GraphQLActiveRecordAutoSelect

  field :actor, Types::Actor, null: false, extras: [:lookahead]

  def actor(lookahead:)
    Actor.autoselect(lookahead).find(object.actor_id)
  end
end
```

And with this query:

```
query {
  organization {
    actor {
      email
    }
  }
}
```

It'll translate this:

```ruby
Actor.autoselect(lookahead).find(object.actor_id)
```

Into this:

```ruby
Actor.select(:id, :email).find(object.actor_id)
```


#### Dependents

You might have fields or methods that depend on the presence of one or more fields. You can specify dependents to ensure that the requested field or method will be able to successfully compute:

```ruby
class Actor < ActiveRecord::Base
  def secret
    decrypt(secret_digest)
  end

  private

  def decrypt(column)
    # ...
  end
end

class Types::Actor < Types::Base::Object
  # ...

  field :email, String, null: false
  field :full_name, String, null: false
  field :secret, String, null: false

  def self.dependents
    {
      :full_name => [:first_name, :last_name],
      :secret    => [:secret_digest],
    }
  end

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  # ...
end

class Types::Organization < Types::Base::Object
  using GraphQLActiveRecordAutoSelect

  field :actor, Types::Actor, null: false, extras: [:lookahead]

  def actor(lookahead:)
    Actor.autoselect(lookahead, Types::Actor.dependents).find(object.actor_id)
  end
end
```

There's a few things to note here.

1. We've defined the `secret` method in the Actor model which decrypts and returns the encrypted data stored in the `secret_digest` column.
2. We've defined `self.dependents` on the `Types::Actor` class which describes which fields depend on what columns.
3. We've passed in that dependent configuration to the second argument of `autoselect`.

We're essentially telling autoselect that if the client selects the `full_name` field, that it has to select the `first_name` and `last_name` columns on the model. Likewise, when selecting the `secret` field, it'll select the `secret_digest` column on the model so that it has the encrypted data it needs to decrypt and return.

```
query {
  organization {
    actor {
      email
      full_name
      secret
    }
  }
}
```

It'll translates this:

```ruby
Actor.autoselect(lookahead, Actor.dependents).find(object.actor_id)
```

Into this:

```ruby
Actor.select(:id, :email, :first_name, :last_name, :secret_digest).find(object.actor_id)
```

Since we've selected the `full_name` and `secret` fields, autoselect selects the `first_name`, `last_name`, and `secret_digest` columns, as these are necessary in order to compute `full_name` and `secret`.


### Contributing

Bug reports and pull requests are welcome on GitHub at:

https://github.com/mrrooijen/graphql_activerecord_autoselect

To install the dependencies:

```
$ bundle
```

To open an interactive console:

```
$ bundle console
```

To run the tests:

```
$ bundle exec rake
```

To view the code coverage (generated after each test run):

```
$ open coverage/index.html
```

To run the local documentation server:

```
$ bundle exec rake doc
```

To build a gem:

```
$ bundle exec rake build
```

To build and install a gem on your local machine:

```
$ bundle exec rake install
```

For a list of available tasks:

```
$ bundle exec rake --tasks
```


### Author / License

Released under the [MIT License] by [Michael van Rooijen].

[Michael van Rooijen]: https://michael.vanrooijen.io
[HireFire]: https://www.hirefire.io
[RubyDoc]: https://rubydoc.info/github/mrrooijen/graphql_activerecord_autoselect/master
[MIT License]: https://github.com/mrrooijen/graphql_activerecord_autoselect/blob/master/LICENSE.txt
[GraphQL (Ruby)]: https://github.com/rmosolgo/graphql-ruby
[ActiveRecord]: https://github.com/rails/rails/tree/master/activerecord
