# Taxonomy Parser

This gem can be used any time there is a need for the ITA Taxonomy, currently housed as XML in Webprotege, to be available on a Ruby back end.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'taxonomy_parser', github: 'GovWizely/taxonomy_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install taxonomy_parser

## Usage

Initialize a new parser and call the parse method to download and parse the terms.  
In order to initialize the parser correctly, you must provide a valid path or URL to a ZIP file containing the OWL files, 
or you can pass in an array of OWL file names (such as ["path/file1.owl", "path/file2.owl", etc.]).
The parser's terms can also be preloaded by passing in an array of terms as the second parameter.  
These terms will be accessible by calling the `terms` method without needing to call `parse`.

```ruby
my_parser = TaxonomyParser.new('path/or/url/to/zip')
my_parser = TaxonomyParser.new(["path/file1.owl", "path/file2.owl"])
my_parser.parse
my_parser = TaxonomyParser.new('path/or/url/to/zip', [ array_of_hash_terms ])
my_parser.terms
```

After calling parse, you can view the concepts, concept groups and concept schemes, in addition to the full list of terms, by calling their respective methods:

```ruby
my_parser.concepts
my_parser.concept_groups
my_parser.concept_schemes
my_parser.terms
```

Each of these methods will return an array of hashes that contain the following symbolized keys:

* label
* subject
* sub_class_of
* annotations
* datatype_properties
* object_properties

An example concept showing the structure:
```ruby
{:annotations=>{:source=>"ITA", :pref_label=>"Market Research Services"},
 :sub_class_of=>
  [{:id=>"http://webprotege.stanford.edu/RZAYCEhJ1RvOk65kuqHWF7",
    :label=>"Marketing Services"}],
 :label=>"Market Research Services",
 :datatype_properties=>{},
 :object_properties=>
  {:member_of=>
    [{:id=>"http://webprotege.stanford.edu/RCSUVZOLMw17ZnTq4SY2JcX",
      :label=>"Product Class"}],
   :has_broader=>
    [{:id=>"http://webprotege.stanford.edu/RZAYCEhJ1RvOk65kuqHWF7",
      :label=>"Marketing Services"}]},
 :subject=>"http://webprotege.stanford.edu/RDV1ccixsBYCOyBPN4RYvkw"}
```

There are a few built in lookup methods:

```ruby
my_parser.get_all_geo_terms_for_country('AF')
my_parser.get_all_geo_terms_for_country('United States')
```
Returns an array of terms that are a member of World Regions and Trade Regions relating to the given country.  This method accepts a country name or ISO-2 code.

```ruby
my_parser.get_concepts_by_concept_group("Countries")
```
Returns an array of terms that are a member of the given concept group.

```ruby
my_parser.get_term_by_label('Aviation')
```
Returns a single hash term given it's name.

```ruby
my_parser.raw_source
```
Returns a string containing a combined version of the raw XML that was provided to the parser's constructor.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GovWizely/taxonomy_parser.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

