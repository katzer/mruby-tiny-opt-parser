# MIT License
#
# Copyright (c) 2018 Sebastian Katzer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

assert 'OptParser#valid_flag?' do
  parser = OptParser.new

  parser.add 'help'
  parser.add 'version'

  assert_true  parser.valid_flag? 'help'
  assert_true  parser.valid_flag? 'v'
  assert_false parser.valid_flag? 'other'
end

assert 'OptParser#opt_given?' do
  parser = OptParser.new

  parser.parse(['--help', '-v'], ignore_unknown: true)

  assert_true  parser.opt_given? 'help'
  assert_true  parser.opt_given? 'h'
  assert_true  parser.opt_given? 'version'
  assert_false parser.opt_given? 'hilfe'
  assert_false parser.opt_given? 'other'
end

assert 'OptParser#unknown_opts' do
  parser = OptParser.new
  parser.add 'help'
  parser.parse(['help'])
  assert_true parser.unknown_opts.empty?

  parser = OptParser.new
  parser.add 'help'
  parser.parse(['--help'])
  assert_true parser.unknown_opts.empty?

  parser = OptParser.new
  parser.add 'help'
  parser.parse(['-h'])
  assert_true parser.unknown_opts.empty?

  parser = OptParser.new
  parser.add 'help'
  parser.parse(['-?'], ignore_unknown: true)
  assert_include parser.unknown_opts, '?'

  parser = OptParser.new
  parser.add 'port'
  parser.parse(['-p', '80'])
  assert_true parser.unknown_opts.empty?
end

assert 'OptParser#opt_value' do
  parser = OptParser.new
  parser.parse(['--port', '8000', '--ip', '0.0.0.0', '-v'], ignore_unknown: true)

  assert_equal '8000', parser.opt_value('port')
  assert_equal '8000', parser.opt_value('p')

  assert_equal '0.0.0.0', parser.opt_value('ip')
  assert_nil   parser.opt_value('v')
  assert_true  parser.opt_value('v', :bool, dval: false)
  assert_equal '1.0.0', parser.opt_value('v', :string, dval: '1.0.0')
end

assert 'OptParser#parse' do
  parser = OptParser.new
  opts   = nil
  port   = nil

  parser.on(:unknown) { |flags| opts = flags || [] }

  parser.parse(['--port', '8000'], ignore_unknown: true)
  assert_nil opts

  parser.parse(['--port', '8000'])
  assert_equal ['port'], parser.unknown_opts
  assert_equal parser.unknown_opts, opts

  parser.on(:port, :int, dval: 80, short: :p) { |p| port = p }
  parser.parse([])
  assert_equal 80, parser.opts[:port]

  parser.parse(['--port'])
  assert_equal 80, port
  parser.parse(['--port', '8080'])
  assert_equal 8080, port
  assert_equal({ port: 8080 }, parser.opts)
end

assert 'OptParser#opts' do
  parser = OptParser.new
  parser.on(:port, :int, dval: 80)
  parser.on(:version, :int, dval: 1)
  parser.on(:verbose, :bool, dval: false, short: :e)
  parser.parse(['--port', '8000'])

  assert_equal({ port: 8000, version: 1, verbose: false }, parser.opts)
end

assert 'OptParser#opts with similar flags' do
  parser = OptParser.new
  parser.on(:port, :int, dval: 80, short: :p)
  parser.on(:parallel, :bool, dval: false, short: :pa)
  parser.parse(['--port', '8000'])

  assert_equal({ port: 8000, parallel: false }, parser.opts)

  parser.parse(['-pa', '-p', '9000'])

  assert_equal({ port: 9000, parallel: true }, parser.opts)
end

assert 'OptParser#tail' do
  parser = OptParser.new
  parser.on(:port, :int)
  parser.parse(['--port', 80, 1, 2])
  assert_equal({ port: 80 }, parser.opts)
  assert_equal [1, 2], parser.tail

  parser = OptParser.new
  parser.parse(%w[port 80])
  assert_equal({}, parser.opts)
  assert_equal %w[port 80], parser.tail

  parser = OptParser.new
  assert_equal([], parser.tail)
end

assert 'OptParser#sample' do
  parser = OptParser.new

  parser.on(:pretty, :bool, dval: false)
  parser.on(:sort, :bool, dval: false)
  parser.on(:field, :string)

  assert_true parser.parse(%w[-p])[:pretty]
  assert_true parser.parse(%w[-p s t])[:pretty]

  parser.parse(%w[-p -f id -s s t])
  assert_equal({ pretty: true, field: 'id', sort: true }, parser.opts)
  assert_equal(%w[s t], parser.tail)
end
