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

      context 'customization of columns with .add_custom_column' do 
        after(:each) do 
          reload_records!
        end

        it 'should allow addition of different columns' do 
          MyCachedRecord.cache_and_delegate(MyRecord) do |cache|
            cache.add_custom_column :my_record_special_foo
          end
          MyCachedRecord.upgrade_schema!

          expect(MyCachedRecord.column_names).to include('my_record_special_foo')
        end

        it 'by default, should raise error if source_class does not respond_to custom column name' do 
          expect{ MyCachedRecord.add_custom_column :not_foo_of_record }.to raise_error NonExistentInstanceMethod
        end


        context ':serialize option' do 
          before(:each) do 
            @source = MyRecord.create
            @the_foo_array = @source.foo_array.dup
          end
          after(:each) do 
            reload_records!
          end

          it 'should accept :serialize => true' do 
            MyCachedRecord.add_custom_column :foo_array, serialize: true
            MyCachedRecord.upgrade_schema!
            cache = MyCachedRecord.create_cache(@source)
            # remove @source to make sure things are cached
            @source.delete 
            cache = MyCachedRecord.find(cache.id)

            expect(cache.foo_array).to be_an Array
            expect(cache.foo_array).to include(*@the_foo_array)
          end


          it 'respects .serialize second argument' do 
            MyCachedRecord.add_custom_column :foo_array, serialize: Hash
            MyCachedRecord.upgrade_schema!
            expect{ MyCachedRecord.create_cache(@source)  }.to raise_error ActiveRecord::SerializationTypeMismatch
          end

        end

        context 'enforcement of responds_to' do 
          it 'should allow adding of columns based on defined instance method' do 
            MyCachedRecord.add_custom_column :superfluous_instance_method
            MyCachedRecord.upgrade_schema!

            expect(MyCachedRecord.column_names.include?('superfluous_instance_method')).to be_true
          end

          context 'respond_to_missing? works' do 
            it 'should allow reference to dynamically defined methods' do 
              MyCachedRecord.add_custom_column :dynamic_foo
              MyCachedRecord.upgrade_schema!

              expect(MyCachedRecord.column_names.include?('dynamic_foo')).to be_true 
            end

          end

          context 'non-existent' do 
            it 'should raise error of undefined instance methods' do 
              expect{ MyCachedRecord.add_custom_column :non_existent_method }.to raise_error NonExistentInstanceMethod
            end

            it 'should not raise error if bespoke is true' do 
              MyCachedRecord.add_custom_column :non_existent_method, bespoke: true 
              MyCachedRecord.upgrade_schema!
              expect(MyCachedRecord.column_names.include?('non_existent_method')).to be_true
            end            
          end
        end


        it 'should allow exclusion of specified columns'


      end
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
      end
    end

    context 'maintanence' do 

        context 'duplicating associated records' do 
          it 'should only duplicate one level down' do 
            pending "dumping to yaml"
          end
        end

    end

  end


end
