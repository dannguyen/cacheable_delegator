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
            expect(MyCachedRecord.column_names).to include( 'values', 'name', 'address', 'question')
          end

          it 'should not erase anything on upgrades' do 
            expect(MyCachedRecord.column_names).to include( 'foo', 'foo_double_values', 'source_record_id')
          end

          it 'should mimic column types and attributes' do 
            a_col = MyCachedRecord.columns.find{|c| c.name == 'address'}
            expect(a_col.limit).to eq 42
            expect(a_col.type).to eq :string
          end
        end

      end

      describe 'should allow addition of different columns'
      describe 'should allow exclusion of specified columns '
    end

    context 'maintanence' do 
    end

  end


end
