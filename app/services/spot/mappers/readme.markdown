# Mappers

`Mapper`s are responsible for taking the parsed raw metadata and mapping it to
Samvera/Hydra model attributes. The `Darlingtonia::MetadataMapper` is abstract
on-purpose. We've added some behavior with `Spot::Mappers::BaseMapper`:

- A class attribute Hash `.fields_map` allows a one-to-one mapping of
  model attribute to source-metadata key.
- A class attribute string `.default_visibility` used to apply to each item.
  The `BaseMapper` uses a metadata heading of `'visibility'`, which needs to
  correspond to the hydra-access-control visibility settings. To change this
  behavior, create a `#visibility` method on your mapper.
- A `#representative_file` method, aliased as `#representative_files` in the
  event that you have multiple. This maps to a metadata heading of `'representative_files'`.
  To change this behavior, create a `#representative_files` method on your mapper.

The `BaseMapper` creates a hash of attributes by calling the `#fields` method
to get an array of methods to call on the mapper. These methods should correspond
to model attribute names. This allows us to use both the `.fields_map` hash for
simple mappings and methods to do more involved work.

```ruby
module Spot::Mappers
  class SomeKindOfNewMapper
    self.fields_map = {
      creator: 'dc:author',
      subject: 'dc:subject'
    }

    # Your `#fields` method should call `super`
    # and add an array of attributes (that are methods)
    # to call in addition.
    def fields
      super + [:title]
    end

    def title
      return metadata['dc:title'].first unless metadata['dc:alternative'].present?
      "#{metadata['dc:title'].first} (#{metadata['dc:alternative'].first})"
    end
  end
end
```

This will convert a metadata hash from:

```ruby
{
  'dc:title' => ['Free Jazz'],
  'dc:alternative' => ['A collective improvisation'],
  'dc:creator' => ['Ornette Coleman Double Quartet'],
  'dc:subject' => ['Jazz', 'Free Jazz']
}
```

to

```ruby
{
  title: 'Free Jazz (A collective improvisation)',
  creator: ['Ornette Coleman Double Quartet'],
  subject: ['Jazz', 'Free Jazz']
}
```

The way this works is by a `#map_field` method, which is called when
a method on the `Mapper` is missing. In our implementation, it uses the
method name and looks for a matching key in the `.fields_map`.
