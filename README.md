# Command-line option analysis for mruby <br> [![Build Status](https://travis-ci.com/katzer/mruby-tiny-opt-parser.svg?branch=master)](https://travis-ci.com/katzer/mruby-tiny-opt-parser) [![Maintainability](https://api.codeclimate.com/v1/badges/7d8bb5bc18ad8da8c3fc/maintainability)](https://codeclimate.com/github/katzer/mruby-tiny-opt-parser/maintainability)

Tiny option parser for [mruby][mruby] with __zero__ dependencies.

```ruby
parser = OptParser.new do |opts|
  opts.on(:port, :int, 80) { |port| ... }
  opts.on(:parallel, :bool, false, short: :a)
  opts.on(:ip, :string, '127.0.0.1') { |ip| ... }
end

parser.parse(['--port', '8000', '-a', 'losthost', 'otherhost'])

parser.opts # => { port: 8000, parallel: true, ip: '127.0.0.1' }
parser.tail # => ['losthost', 'otherhost']
```

## Installation

Add the line below to your `build_config.rb`:

```ruby
MRuby::Build.new do |conf|
  # ... (snip) ...
  conf.gem 'mruby-tiny-opt-parser'
end
```

Or add this line to your aplication's `mrbgem.rake`:

```ruby
MRuby::Gem::Specification.new('your-mrbgem') do |spec|
  # ... (snip) ...
  spec.add_dependency 'mruby-tiny-opt-parser'
end
```

## Development

Clone the repo:
    
    $ git clone https://github.com/katzer/mruby-tiny-opt-parser.git && cd mruby-tiny-opt-parser/

Compile the source:

    $ rake compile

Run the tests:

    $ rake test

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katzer/mruby-tiny-opt-parser.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

- Sebastián Katzer, Fa. appPlant GmbH

## License

The mgem is available as open source under the terms of the [MIT License][license].

Made with :yum: in Leipzig

© 2018 [appPlant GmbH][appplant]

[mruby]: https://github.com/mruby/mruby
[license]: http://opensource.org/licenses/MIT
[appplant]: www.appplant.de
