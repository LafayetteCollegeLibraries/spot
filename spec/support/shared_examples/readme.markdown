# Shared RSpec examples

There are a lot of them here, and some of them are deprecated post-Valkyrization, so here's what's what:

file                                    | it_behaves_like                                                                               | notes
----------------------------------------|-----------------------------------------------------------------------------------------------|----------
collections_controller_with_slugs.rb            | `'it locates a collection with a slug identifier'`                                    |
image_derivatives.rb                            | `'it exports image derivatives'`                                                      |
logs_a_warning.rb                               | `'it logs a warning'`                                                                 |
metadata_only_visibility.rb                     | `'it accepts "metadata" as a visibility'`                                             | needs to be updated for Valkyrization
record_importer.rb                              | `'a RecordImporter'`                                                                  | deprecated, used for Darlingtonia importers
renders_attribute_to_html.rb                    | `'it renders an attribute to HTML'`                                                   |
spot_base_actor.rb                              | `'a Spot actor'`                                                                      | deprecated (ActorStack)
spot_core_metadata.rb                           | `'it includes Spot::CoreMetadata'`                                                    | deprecated (ActiveFedora)
spot_presenter.rb                               | `'a Spot presenter'`                                                                  |
spot_work_behavior.rb                           | `'it includes Spot::WorkBehavior'`                                                    | deprecated (ActiveFedora)
spot_workflow_notification.rb                   | `'a Spot::Workflow notification'`                                                     |
spot_works_controller.rb                        | `'it includes Spot::WorksControllerBehavior'`                                         |
forms/hyrax_form_fields.rb                      | `'it includes Hyrax::FormFields', schema: :schema`                                    | requires `:schema` parameter
forms/hyrax_permitted_params.rb                 | `'it builds Hyrax permitted params'`                                                  | deprecated (Hyrax < 6)
forms/identifier_fields.rb                      | `'it handles identifier form fields'`                                                 | deprecated (Hyrax < 6), replaced with `forms/identifier_form_fields.rb`
forms/identifier_form_fields.rb                 | `'it supports local/standard identifiers'`                                            |
forms/language_tagged_literal.rb                | `'a parsed language-tagged literal (single)'`                                         | deprecated (Hyrax < 6), replaced with `forms/language_tagged_resource_field.rb`
\------                                         | `'a parsed language-tagged literal (multiple)'`                                       | deprecated (Hyrax < 6)
forms/language_tagged_resource_field.rb         | `'a language-tagged resource field'`                                                  |
forms/nested_attribute_resource_field.rb        | `'a nested attribute field'`                                                          |
forms/primary_terms_form_hints.rb               | `'it has hints for all primary_terms'`                                                | revisit for Valkyrization?
forms/required_fields.rb                        | `'it handles required fields'`                                                        | revisit for Valkyrization?
forms/spot_work_form.rb                         | `'a Spot work form'`                                                                  | deprecated (Hyrax < 6)
forms/strips_whitespace.rb                      | `'it strips whitespaces from values'`                                                 | revisit for Valkyrization?
forms/transforms_local_vocabulary_attributes.rb | `'it transforms a local vocabulary attribute'`                                        | deprecated (Hyrax < 6)
indexing/base_resource_indexer.rb               | `'a BaseResourceIndexer'`                                                             |
indexing/indexes_a_field.rb                     | `'it indexes', field, to: ['field_ssim']`                                             | requires `field`, and `to:` or `to_fields:` params
indexing/indexes_english_language_dates.rb      | `'it indexes English-language dates'`                                                 | deprecated (Hyrax < 6), see `indexing/base_resource_indexer.rb`
indexing/indexes_permalink.rb                   | `'it indexes a permalink'`                                                            | deprecated (Hyrax < 6), see `indexing/base_resource_indexer.rb`
indexing/indexes_sortable_date.rb               | `'it indexes a sortable date'`                                                        | deprecated (Hyrax < 6), see `indexing/base_resource_indexer.rb`
indexing/simple_model_indexing.rb               | `'simple model indexing'`                                                             | deprecated (Hyrax < 6), see `indexing/base_resource_indexer.rb`
indexing/spot_indexer.rb                        | `'a Spot indexer'`                                                                    | deprecated (Hyrax < 6), see `indexing/base_resource_indexer.rb`
presenters/html_line_breaks.rb                  | `'it replaces line breaks with HTML', for: [:fields]`                                 | requires `for:` array of fields
presenters/humanizes_date_fields.rb             | `'it humanizes date fields', for: [:fields]`                                          | requires `for:` array of fields
validations/edtf_dates.rb                       | `'it validates EDTF date fields', fields: [:field]`                                   | requires `fields:` array of fields
validations/field_presence.rb                   | `'it validates field presence', field: :field`                                        | requires singular `field:` parameter
validations/validates_local_authorities.rb      | `'it validates local authorities', field: :resource_type, authority: 'resource_types` |