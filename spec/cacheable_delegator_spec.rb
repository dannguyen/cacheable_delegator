require 'spec_helper'

describe CacheableDelegator do
  before(:each) do 
    MyCachedRecord.upgrade_schema!
  end

  context 'class methods' do 
    describe '.cache_and_delegate' do 
      it 'should accept only a class to cache' do 
        expect{ MyCachedRecord.cache_and_delegate("X::Foo") }.to raise_error ArgumentError
      end

      it 'should set the :source_class attribute' do 
        MyCachedRecord.cache_and_delegate MyRecord
        expect(MyCachedRecord.source_class).to eq MyRecord
      end
    end
  end


  context 'delegated methods via method_missing' do 

    before(:each) do 
      @source = MyRecord.new(awesome_value: 500)
      @source.my_covers << MyCover.new(subject: 'Funny', year: 2000) << MyCover.new(subject: 'Yes')      
      @source.save

      @cache = MyCachedRecord.create_cache(@source)
    end

    context 'ActiveRecord relations' do 
      it 'should have the same relations as its source' do 
        expect(@cache.my_covers.count).to eq 2
      end
    end
  end

  context 'explicit delegations' do 
    context 'it should delegate all the things' do 
      before(:each) do 
        @my_record = MyRecord.create(name: 'Namond')
        @cache_record = MyCachedRecord.create
        @cache_record.source_record = @my_record

        @cache_record.save
      end

      it 'should not take in source_record atts unless explicitly commanded' do 
        expect(@cache_record.name).to_not eq 'Namond'
      end

      it 'should have a :source_record through the #belongs_to relation' do 
        expect(@cache_record.source_record).to eq @my_record
      end

      it 'delegate_:column will :delegate to its object' do
        expect(@cache_record.delegate_foo).to eq @my_record.foo
      end

      it 'will always use its own :foo, without :delegate_ prefix' do 
        @cache_record.foo = 'baz'
        expect(@cache_record.foo).to eq 'baz'
      end
    end
  end


  context 'cache building and refreshing' do 
    before do
      @my_record = MyRecord.create(name: 'Namond', awesome_value: 10)
      @cache_record = MyCachedRecord.create_cache(@my_record)
    end

    describe '.create_cache' do
   
      it 'should create a new cached_record' do
        expect(@cache_record).to be_valid 
        expect(@cache_record).not_to be_new_record
      end

      it 'should associate cache_record\'s source_record' do 
        expect(@cache_record.source_record).to eq @my_record
      end

      it 'should have same column data values' do 
        expect(@cache_record.name).to eq 'Namond'
      end

      it 'should have derived values' do 
        expect(@cache_record.read_attribute :foo_double_awesome_value).to eq @my_record.send :foo_double_awesome_value
      end
    end

    describe '#refresh_cache' do 
      it 'should assign attributes, not update them' do
        @my_record.update_attributes name: 'Mike'
        @cache_record.refresh_cache

        expect(@cache_record).to be_changed
      end
    end

    describe '#refresh_cache!' do
      before(:each) do 
        @my_record.update_attributes(name: 'Randy', awesome_value: 99)
        @cache_record.refresh_cache!
      end

      it 'should update the column data values' do
        expect(@cache_record.name).to eq 'Randy'
      end

      it 'should update the derived values' do 
        expect(@cache_record.read_attribute :foo_double_awesome_value).to eq @my_record.send :foo_double_awesome_value
      end
    end
  end

  



end
