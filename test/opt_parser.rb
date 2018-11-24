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
  parser = OptParser.new ['--help', '-v']

  assert_true  parser.opt_given? 'help'
  assert_true  parser.opt_given? 'h'
  assert_true  parser.opt_given? 'version'
  assert_false parser.opt_given? 'hilfe'
  assert_false parser.opt_given? 'other'
end

assert 'OptParser#unknown_opts' do
  parser = OptParser.new ['help']
  parser.add 'help'
  assert_true parser.unknown_opts.empty?

  parser = OptParser.new ['--help']
  parser.add 'help'
  assert_true parser.unknown_opts.empty?

  parser = OptParser.new ['-h']
  parser.add 'help'
  assert_true parser.unknown_opts.empty?

  parser = OptParser.new ['-?']
  parser.add 'help'
  assert_include parser.unknown_opts, '?'

  parser = OptParser.new ['-p', '80']
  parser.add 'port'
  assert_true parser.unknown_opts.empty?
end

assert 'OptParser#opt_value' do
  parser = OptParser.new ['--port', '8000', '--ip', '0.0.0.0', '-v']

  assert_equal '8000', parser.opt_value('port')
  assert_equal '8000', parser.opt_value('p')
  assert_equal '0.0.0.0', parser.opt_value('ip')
  assert_nil parser.opt_value('v')
  assert_equal '1.0.0', parser.opt_value('v', :string, '1.0.0')
end

assert 'OptParser#parse' do
  parser = OptParser.new
  opts   = nil
  port   = nil

  parser.on(:unknown) { |flags| opts = flags || [] }

  parser.parse(['--port', '8000'], true)
  assert_nil opts

  parser.parse(['--port', '8000'])
  assert_equal ['port'], parser.unknown_opts
  assert_equal parser.unknown_opts, opts

  parser.on(:port, :int, 80) { |p| port = p }
  parser.parse(['--port'])
  assert_equal 80, port
  parser.parse(['--port', '8080'])
  assert_equal 8080, port
  assert_equal({ port: 8080 }, parser.parse)
end

assert 'OptParser#opts' do
  parser = OptParser.new ['--port', '8000']

  parser.on(:port, :int, 80)
  parser.on(:version, :int, 1)

  assert_equal({ port: 8000, version: 1 }, parser.opts)
end

assert 'OptParser#tail' do
  parser = OptParser.new ['--port', 80, 1, 2]
  parser.on(:port, :int)

  assert_equal({ port: 80 }, parser.opts)
  assert_equal [1, 2], parser.tail

  parser = OptParser.new %w[port 80]
  assert_equal({}, parser.opts)
  assert_equal %w[port 80], parser.tail

  parser = OptParser.new
  assert_equal([], parser.tail)
end
