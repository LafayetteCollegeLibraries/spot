# Importers

Spot uses [Darlingtonia] to build out its work ingest tools.

The concepts introduced by Darlingtonia are:

- Importer
- RecordImporter
- InputRecord
- Parser
- Mapper
- Validator

## Importer

The Darlingtonia importer takes `parser:` and `record_importer:` keyword arguments to
initialize. The standard invocation of the importer (and thus, the import process)
is as simple as:

```ruby
importer = Darlingtonia::Importer.new(parser: parser, record_importer: record_importer)
importer.import if parser.validate!
```

Since `Darlingtonia::Importer` forwards most of the work to the `parser` and `record_importer`,
we've chosen to simply use the `Darlingtonia::Importer`.

## Parser

The `Parser` is responsible for taking in a _thing_ and yielding `Darlingtonia::InputRecord`s
with the `#records` method. It is also responsible for validating the input object.

Within our codebase, these are found at `app/services/spot/importers/<importer-type>/parser.rb`

Out of the box, Darlingtonia wants the `Parser` to take a `file:` keyword argument (pointing
to, say, a CSV file), iterating through each line of that file and creating an `InputRecord`
for each object. It also has mechanisms for implementing a `#match?` method used to determine
whether the subclassed Parser can handle the file type provided.

For the migration, we've decided to _not_ use this functionality (see [Spot::Importers::Bag::Parser]).
Instead, we've taken the pattern of providing the _thing_ (in the forthcoming example,
this is a BagIt-style directory) and mapper to generate the records.

```ruby
bag_directory = '/path/to/a/bag_directory'
mapper = Spot::Mappers::ShakespeareBulletinMapper.new
parser = Spot::Importers::Bag::Parser.new(directory: bag_directory, mapper: mapper)
```

As stated above, `Parser`s are also responsible for validating the _thing_. These validators
are found in a `DEFAULT_VALIDATORS` array. [See their section for details.](#validator)

The parser needs to define a `#records` method that yields an array of `Darlingtonia::InputRecord`s,
one for each item found in the `file:` (or, in the case of the Bag parser, the `directory:`).
These can be created by calling `Darlingtonia::InputRecord.from(metadata:, mapper:)`.

## Record Importer

RecordImporters are responsible for taking the attributes created with the [Mapper](#mapper)
and using them to create a new work type.

Within our codebase, these are found at `app/services/spot/importers/<importer-type>/record_importer.rb`.

For our general use-cases, the [`Spot::Importers::Base::RecordImporter`] should suffice.
This inherits from `Darlingtonia::RecordImporter` and is straight-forward to initialize:

```ruby
record_importer = Spot::Importers::Base::RecordImporter.new(work_class: GenericWork)
```

Other keyword options include: `admin_set_id:`, `info_stream:`, and `error_stream:`.

`admin_set_id:` is pretty much what you'd expect: specify an id and the item being ingested
will be added to that admin_set. By default, this uses the default admin_set.

`info_stream:` and `error_stream:` are used to pass messages during the ingest.
It needs to be stated that these are supposed to be _streams_, rather than loggers, that
respond to the shovel (`<<`) operator. We've created a simple wrapper to allow you
to use a Logger instance instead. This is the [`Spot::StreamLogger`]:

```ruby
info_stream = Spot::StreamLogger.new(Rails.logger, level: Logger::INFO)
error_stream = Spot::StreamLogger.new(Rails.logger, level: Logger::WARN)
```

These can now be passed to the `RecordImporter` to use the Rails logger with importing:

```ruby
record_importer = Spot::Importers::Base::RecordImporter.new(work_class: GenericWork,
                                                            info_stream: info_stream,
                                                            error_stream: error_stream)
```

When importing, if an item does not have a file attached to it, the `RecordImporter`
will log a warning saying so. To specify this message for a different importer, subclass
the base importer and define an `#empty_file_warning` private method.

```ruby
module Spot::Importers::NewType
  class RecordImporter < Spot::Importers::Base::RecordImporter
    private

      def empty_file_warning(attributes)
        "[WARN] there isn't a file attached to #{Array.wrap(attributes[:title]).first}\n"
      end
  end
end
```

## Mappers

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

Within our codebase, these are found at `app/services/spot/mappers/<name>_mapper.rb`.

## Validator

`Validator`s are used to ensure the incoming object is up to snuff.

Within our codebase, these are found at `app/services/spot/validators/<name>_validator.rb`.

To create a validator, inherit from `Darlingtonia::Validator` and define a `#run_validation`
private method which takes a `parser:` as an argument. This method needs to return an array
of error messages if any come up. An empty array will represent a valid item.

```ruby
module Spot::Validators
  class HasFileValidator < ::Darlingtonia::Validator
    private

      def run_validation(parser:)
        parser.records.each_with_object([]) do |record, errors|
          files = record.representative_files
          errors << "No file found for #{record.title.first}" if Array.wrap(files).empty?
        end
      end
  end
end
```

To add validations to your parser, instantiate new `Validators` in the parser's
`DEFAULT_VALIDATIONS` array.

```ruby
module Spot::Importers::NewType
  class Parser < Darlingtonia::Parser
    DEFAULT_VALIDATIONS = [Spot::Validators::HasFileValidator.new].freeze

    # ...
  end
end
```


[Darlingtonia]: https://github.com/curationexperts/darlingtonia
[`Spot::Importers::Base::RecordImporter`]: https://github.com/LafayetteCollegeLibraries/spot/blob/master/app/services/spot/importers/base/record_importer.rb
[Spot::Importers::Bag::Parser]: https://github.com/LafayetteCollegeLibraries/spot/blob/master/app/services/spot/importers/bag/parser.rb
[`Spot::StreamLogger`]: https://github.com/LafayetteCollegeLibraries/spot/blob/master/app/services/spot/stream_logger.rb
