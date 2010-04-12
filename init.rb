# Include hook code here

require 'query_reviewer'

if QueryReviewer.enabled?
  adapter = ActiveRecord::ConnectionAdapters::MysqlAdapter
  
  # Special handling for JRuby
  if RUBY_PLATFORM =~ /java/
    # Target JdbcAdapter directly
    adapter = ActiveRecord::ConnectionAdapters::JdbcAdapter
    
    # Patch JdbcConnection if it does not treat EXPLAIN as a query
    if ActiveRecord::ConnectionAdapters::JdbcConnection.select?("explain") == false
      ActiveRecord::ConnectionAdapters::JdbcConnection.class_eval do
        class << self
          def select_with_explain?(sql)
            select_without_explain?(sql) || !!(sql.strip =~ /^explain/i)
          end
          alias_method_chain :select?, :explain
        end
      end
    end
  end
  
  adapter.send(:include, QueryReviewer::MysqlAdapterExtensions)
  ActionController::Base.send(:include, QueryReviewer::ControllerExtensions)
  Array.send(:include, QueryReviewer::ArrayExtensions)
  
  if ActionController::Base.respond_to?(:append_view_path)
    ActionController::Base.append_view_path(File.dirname(__FILE__) + "/lib/query_reviewer/views")
  end
end
