# Validators

`Validator`s are used to ensure the incoming object meets certain criteria.

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
