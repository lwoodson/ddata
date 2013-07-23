require 'ddata'

module Ddata
  class Hash
    def initialize(opts={})
      @connection = opts[:connection]
      @key = opts[:key]
      @default = opts[:default]
    end

    def method_missing(method, *args)
      delegate = __getobj__
      delegate.send(method, *args).tap do
        if delegate.empty?
          @connection.del(@key)
        else
          __setobj__(delegate)
        end
      end
    end

    def __getobj__
      @connection.hgetall(@key).inject(::Hash.new(@default)) do |memo, kv|
        memo[kv[0]] = kv[1] ? Marshal.load(kv[1]) : @default
        memo
      end
    end

    def __setobj__(obj)
      obj.each do |k, v|
        @connection.hset(@key, k, Marshal.dump(v))
      end
    end
  end
end
