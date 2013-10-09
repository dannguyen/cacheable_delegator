require 'spec_helper'

describe CacheableDelegator do

  context 'class methods' do 

    describe '.cache_and_delegate' do 
      it 'should accept only a class to cache' do 
        expect{ MyCachedRecord.cache_and_delegate("X::Foo") }.to raise_error ArgumentError
      end

      it 'should set the :cached_class attribute' do 
        MyCachedRecord.cache_and_delegate MyRecord
        expect(MyCachedRecord.cached_class).to eq MyRecord
      end
    end
  end


  context 'delegations' do 
    context 'it should delegate all the things' do 
      before(:each) do 
        @my_record = MyRecord.create
        @cache_record = MyCachedRecord.create
        @cache_record.source_record = @my_record

        @cache_record.save
      end

      it 'should have a :source_record through the #belongs_to relation' do 
        expect(@cache_record.source_record).to eq @my_record
      end

      it 'delegate_:column will :delegate to its object' do
        expect(@cache_record.delegate_foo).to eq @my_record.foo
      end


      it 'will use its own :foo, without :delegate_ prefix' do 
        @cache_record.foo = 'baz'
        expect(@cache_record.foo).to eq 'baz'
      end     

    end
  end
end
