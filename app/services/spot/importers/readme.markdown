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
Samvera/Hydra model attributes. Within our codebase, these are found at
`app/services/spot/mappers/<name>_mapper.rb`. See the
[readme document](mapper-readme) for more details.

## Validators

`Validator`s are used to ensure the incoming object meets certain criteria.
Within our codebase, these are found at `app/services/spot/validators/<name>_validator.rb`.
See the [readme document](validator-readme) for more details.


[Darlingtonia]: https://github.com/curationexperts/darlingtonia
[`Spot::Importers::Base::RecordImporter`]: https://github.com/LafayetteCollegeLibraries/spot/blob/master/app/services/spot/importers/base/record_importer.rb
[Spot::Importers::Bag::Parser]: https://github.com/LafayetteCollegeLibraries/spot/blob/master/app/services/spot/importers/bag/parser.rb
[`Spot::StreamLogger`]: https://github.com/LafayetteCollegeLibraries/spot/blob/master/app/services/spot/stream_logger.rb
[mapper-readme]: https://github.com/LafayetteCollegeLibraries/spot/blob/master/app/services/spot/mappers/readme.markdown
[validator-readme]: https://github.com/LafayetteCollegeLibraries/spot/blob/master/app/services/spot/validators/readme.markdown
