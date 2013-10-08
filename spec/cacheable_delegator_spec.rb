require 'spec_helper'

describe CacheableDelegator do

  context 'class methods' do 
      module X
        class Foo; end
        class Baz
          include CacheableDelegator
        end
      end
    describe '.cache_and_delegate' do 
      it 'should accept only a class to cache' do 
        expect{ X::Baz.cache_and_delegate("X::Foo") }.to raise_error ArgumentError
      end
    end

    it 'should have calculated_columns minus id, timestamps, etc' do 

    end
  end


  context 'delegations' do 
    it 'should delegate all' do 

    end
  end


  pending "add some examples to (or delete) #{__FILE__}"
end
