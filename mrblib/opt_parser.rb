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

class OptParser
  # Initialize the parser and check for unknown options.
  #
  # @param [ Array<String> ] args List of command-line arguments.
  #
  # @return [ OptParser ]
  def initialize(args = [])
    normalize_args(args)

    @opts    = {}
    @unknown = ->(opts) { raise "unknown option: #{opts.join ', '}" }

    yield(self) if block_given?
  end

  # The tail of the argument list.
  #
  # @return [ Array<String> ]
  attr_reader :tail

  # Add a flag and a callback to invoke if flag is given later.
  #
  # @param [ String ] flag The name of the option value.
  #                        Possible values: any, string, int, float, bool
  # @param [ Symbol ] type The type of the option v
  # @param [ Object ] dval The value to use if nothing else given.
  # @param [ Proc ]   blk  The callback to be invoked.
  #
  # @return [ Void ]
  def on(opt, type = :string, dval = nil, &blk)
    if opt == :unknown
      @unknown = blk
    else
      @opts[opt.to_s] = [type, dval, blk]
    end
  end

  alias add on

  # Same as `on` however is does exit after the block has been called.
  #
  # @return [ Void ]
  def on!(opt, type = :string, dval = nil)
    on(opt, type, dval) do |val|
      if opt_given? opt.to_s
        puts yield(val)
        exit
      end
    end
  end

  # Parse all given flags and invoke their callback.
  #
  # @param [ Array<String> ] args List of arguments to parse.
  # @param [ Bool]           ignore_unknown
  #
  # @return [ Hash<String, Object> ]
  def parse(args = nil, ignore_unknown = false)
    params = {}

    normalize_args(args) if args

    @unknown.call(unknown_opts) if !ignore_unknown && unknown_opts.any?

    @opts.each do |opt, opts|
      type, dval, blk    = opts
      val                = opt_value(opt, type, dval)
      params[opt.to_sym] = val unless val.nil?

      blk&.call(val)
    end

    params
  end

  # Returns a hash with all opts and their value.
  #
  # @return [ Hash<String, Object> ]
  def opts
    params = {}
    @opts.each { |opt, opts| params[opt.to_sym] = opt_value(opt, *opts[0, 2]) }
    params
  end

  # List of all unknown options.
  #
  # @return [ Array<String> ]
  def unknown_opts
    @args.reject { |opt| !opt.is_a?(String) || valid_flag?(opt) }
  end

  # If the specified flag is given in opts list.
  #
  # @param [ String ] name The (long) flag name.
  #
  # @return [ Boolean ]
  def valid_flag?(flag)
    if flag.length == 1
      @opts.keys.any? { |opt| opt[0] == flag[0] }
    else
      @opts.include?(flag)
    end
  end

  # If the specified flag is given in args list.
  #
  # @param [ String ] opt The (long) flag name.
  #
  # @return [ Boolean ]
  def opt_given?(opt)
    @args.any? do |arg|
      if opt.length == 1 || arg.length == 1
        true if arg[0] == opt[0]
      else
        arg == opt
      end
    end
  end

  # Extract the value of the specified options.
  # Raises an error if the option has been specified but without an value.
  #
  # @param [ String ] opt  The option to look for.
  # @param [ Object ] dval The default value to use for unless specified.
  #
  # @return [ Object ]
  def opt_value(opt, type = :any, dval = nil)
    pos = @args.index(opt)
    @args.each_index { |i| pos = i if !pos && opt[0] == @args[i][0] } unless pos
    val = @args[pos + 1] if pos

    case val
    when Array then convert(val[0], type)
    when nil   then dval
    else convert(val, type)
    end
  end

  private

  # Convert the value into the specified type.
  # Raises an error for unknown type.
  #
  # @param [ Object ] val  The value to convert.
  # @param [ Symbol ] type The type to convert into.
  #                        Possible values: any, string, int, float, bool
  #
  # @return [ Object] The converted value.
  def convert(val, type)
    case type
    when :any    then val
    when :string then val.to_s
    when :int    then val.to_i
    when :float  then val.to_f
    when :bool   then val && (val != '0' || val != 'off')
    else raise "Cannot convert #{val} into #{type}."
    end
  end

  # Removes all leading slashes or false friends from args.
  #
  # @param [ Array<String> ] args The arguments to normalize.
  #
  # @return [ Void ]
  def normalize_args(args)
    @args = []
    @tail = []
    flag  = false

    args.each do |opt|
      if opt.to_s[0] == '-'
        @args << opt[(opt[1] == '-' ? 2 : 1)..-1]
        flag = false
      elsif flag
        @tail << opt
      else
        @args << [opt]
        flag = true
      end
    end
  end
end
