# Provides a way to send :connection through ActiveSupport notifications to avoid
# looping through connection handlers to locate a connection by connection_id
# This is not needed in Rails 6+: https://github.com/rails/rails/pull/34602

module NewRelic
  module Agent
    module Instrumentation
      module ActiveRecordNotifications
        module BaseExtensions41
          # https://github.com/rails/rails/blob/4-1-stable/activerecord/lib/active_record/connection_adapters/abstract_adapter.rb#L371
          def log(sql, name = "SQL", binds = [], statement_name = nil)
            @instrumenter.instrument(
              "sql.active_record",
              :sql            => sql,
              :name           => name,
              :connection_id  => object_id,
              :connection     => self,
              :statement_name => statement_name,
              :binds          => binds) { yield }
          rescue => e
            raise translate_exception_class(e, sql)
          end
        end

        module BaseExtensions50
          # https://github.com/rails/rails/blob/5-0-stable/activerecord/lib/active_record/connection_adapters/abstract_adapter.rb#L582
          def log(sql, name = "SQL", binds = [], type_casted_binds = [], statement_name = nil)
            @instrumenter.instrument(
              "sql.active_record",
              sql:               sql,
              name:              name,
              binds:             binds,
              type_casted_binds: type_casted_binds,
              statement_name:    statement_name,
              connection_id:     object_id,
              connection:        self) { yield }
          rescue => e
            raise translate_exception_class(e, sql)
          end
        end

        module BaseExtensions51
          # https://github.com/rails/rails/blob/5-1-stable/activerecord/lib/active_record/connection_adapters/abstract_adapter.rb#L603
          def log(sql, name = "SQL", binds = [], type_casted_binds = [], statement_name = nil) # :doc:
            @instrumenter.instrument(
              "sql.active_record",
              sql:               sql,
              name:              name,
              binds:             binds,
              type_casted_binds: type_casted_binds,
              statement_name:    statement_name,
              connection_id:     object_id,
              connection:        self) do
                @lock.synchronize do
                  yield
                end
              end
          rescue => e
            raise translate_exception_class(e, sql)
          end
        end
      end
    end
  end
end
