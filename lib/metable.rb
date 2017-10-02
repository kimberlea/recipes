module Metable

  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.notify_connection(channel, opts={})
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      conn = connection.instance_variable_get(:@connection)
      conn.async_exec("NOTIFY #{channel}")
    end
  end

  def self.wait_for_notify_then_run(channels, opts={}, &block)
    timeout = opts[:timeout] || 15
    logger = opts[:logger]
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      conn = connection.instance_variable_get(:@connection)
      channels.each do |c|
        conn.async_exec("LISTEN #{c}")
      end
      loop do
        begin
          str = conn.wait_for_notify(timeout)
          block.call({channel: str})
        rescue => ex
          if ex.is_a?(Interrupt)
            logger.info "Wait for notify interrupted, stopping."
            break
          end
          if logger
            logger.info e.message
            logger.info e.backtrace.join("\n\t")
          end
          sleep 1
        end
      end
      conn.async_exec("UNLISTEN *")
    end
  end

  module ClassMethods

    def metable!
      if self.respond_to?(:field)
        field :meta_graph_updated_at, type: Time
        field :meta_updated_at, type: Time
        field :meta, type: Hash
        index [:meta_graph_updated_at]
        index [:meta_updated_at]
      end
      scope :needs_meta_update, lambda {
        where("meta_updated_at IS NULL OR (meta_graph_updated_at > meta_updated_at)")
      }
    end

    def process_meta(opts={})
      self.process_each!(needs_meta_update, id: 'process_meta') do |m|
        m.update_meta
      end
    end

    def meta_graph_updated(scope = nil)
      scope ||= self.all
      scope.update_all(meta_graph_updated: Time.now)
    end

  end ## END CLASS METHODS

  def meta_graph_updated_for(*models)
    t = Time.now
    models.each do |model|
      next if model.nil?
      if model.respond_to?(:update_all)
        model.update_all(meta_graph_updated_at: t)
      else
        model.update_attribute(:meta_graph_updated_at, t)
      end
    end
    Metable.notify_connection("meta_graph_updated")
  end

  def meta
    self['meta'] ||= {}
    self['meta']
  end

end
