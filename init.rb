# Include hook code here

require 'query_reviewer'

if QueryReviewer.enabled?
  case RUBY_PLATFORM  
  when /java/
    ActiveRecord::ConnectionAdapters::JdbcAdapter
  else
    ActiveRecord::ConnectionAdapters::MysqlAdapter
  end.send(:include, QueryReviewer::MysqlAdapterExtensions)
  ActionController::Base.send(:include, QueryReviewer::ControllerExtensions)
  Array.send(:include, QueryReviewer::ArrayExtensions)
  
  if ActionController::Base.respond_to?(:append_view_path)
    ActionController::Base.append_view_path(File.dirname(__FILE__) + "/lib/query_reviewer/views")
  end
end
