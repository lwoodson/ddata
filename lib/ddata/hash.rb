require 'ddata'
require 'redis-semaphore'

module Ddata
  class Hash
    def initialize(opts={})
      @connection = opts[:connection]
      @key = opts[:key]
      @default = opts[:default]
      @semaphore = Redis::Semaphore.new(@key, redis: @connection) 
    end

    def method_missing(method, *args)
      @semaphore.lock do
        delegate = __getobj__
        return delegate.send(method, *args).tap do |result|
          if delegate.empty?
            @connection.del(@key)
          else
            __setobj__(delegate)
          end
        end
      end
    end

    def __getobj__
      return @connection.hgetall(@key).inject(::Hash.new(@default)) do |memo, kv|
        memo[kv[0]] = kv[1] ? Marshal.load(kv[1]) : @default
        memo
      end
    end

    def __setobj__(obj)
      obj.each do |k, v|
        @connection.hset(@key, k, Marshal.dump(v))
      end
    end

    # TODO finalizer to clean up redis when obj reclaimed.
  end
end
