require 'spec_helper'

describe CacheableDelegator do

  context 'compatability with active_record_inline_schema' do 
    context 'create schema based on @@source_class ' do 

      describe '.upgrade_schema! effects' do
        describe 'default call' do 
          before(:each) do 
            MyCachedRecord.upgrade_schema!
          end

          after(:each) do 
            reload_records!
          end

          it 'should mimic column names' do 
            # in spec_records.rb, the default call is invoked
            expect(MyCachedRecord.column_names).to include( 'awesome_value', 'name', 'address', 'question')
          end

          it 'should not erase anything on upgrades' do 
            expect(MyCachedRecord.column_names).to include( 'foo', 'foo_double_awesome_value', 'source_record_id')
          end

          it 'should mimic column types and attributes' do 
            a_col = MyCachedRecord.columns.find{|c| c.name == 'address'}
            expect(a_col.limit).to eq 42
            expect(a_col.type).to eq :string
          end
        end
      end

      it 'should allow addition of different columns'
      it 'should allow exclusion of specified columns'
    end


    context 'record building' do 
      before(:each) do
        MyCachedRecord.upgrade_schema!

        @source = MyRecord.create awesome_value: 88
        @cache = MyCachedRecord.build_cache(@source)
      end


      describe '#build_cache' do 
        

        it 'should have same awesome_value as its source_object' do 
          expect(@cache.awesome_value).to eq 88
        end

        it 'should also have expected derived awesome_value in its column' do 
          expect(@cache.foo_double_awesome_value).to eq @source.foo_double_awesome_value
        end

        it 'should be associated to source_object' do 
          expect(@cache.source_record).to be @source
        end
      end

      describe '#create_cache' do
        it 'should be a saved record' do 
          savedcache = MyCachedRecord.create_cache(@source)
          expect(savedcache.valid?).to be_true
          expect(savedcache.new_record?).to be_false
        end

      
        context 'duplicating associated records' do 
          it 'should only duplicate one level down'
        end

      end



    end

    context 'maintanence' do 
    end

  end


end
