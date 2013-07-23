require 'ddata/hash'

describe Ddata::Hash do
  let(:redis) {Redis.new}
  let(:dhash) {Ddata::Hash.new(connection: redis, key: 'ddata-hash')}

  before {redis.flushdb}

  describe "#__setobj__ & #__getobj__" do
    it "should store hash in redis" do
      dhash.__setobj__(a: 1, b: 2)
      redis.keys.should == ['ddata-hash']
      result = dhash.__getobj__
      result['a'].should == 1
      result['b'].should == 2
    end
  end

  context "with 2 elements" do
    before do
      dhash['a'] = 1
      dhash['b'] = 2
      dhash = Ddata::Hash.new(connection: redis, key: 'ddata-hash')
    end

    describe "#[] and #[]=" do
      it "should retrieve data from redis" do
        dhash['a'].should == 1
        dhash['b'].should == 2
      end
    end

    describe "#keys" do
      it "should return all keys from redis" do
        dhash.keys.should == ['a','b']
      end
    end

    describe "#values" do
      it "should return all values from redis" do
        dhash.values.should == [1,2]
      end
    end

    describe "#clear" do
      it "should clear the data from redis" do
        dhash.clear
        redis.keys.should == []
      end
    end
  end
end

