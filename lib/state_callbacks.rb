module StateCallbacks
  def self.included(base)
    #base.extend StateClassMethods
  end

  class CallbackHandler
    attr_reader :after, :before

    def add(from, to, _when = :after, &block)
      callbacks_hash(_when)[[from.to_s, to.to_s]] = block.to_proc
    end

    def get(from, to, _when = :after)
      callbacks_hash(_when).find { |(k,v)|
        from.to_s == k[0].to_s && to.to_s == k[1].to_s
      }.try(:last)
    end

    private
      def callbacks_hash(_when)
        callbacks_hash = case _when
          when :after then @after ||= {}
          when :before then @before ||= {}
        end
      end
  end

  #module StateClassMethods
    def on(from, to, options = {}, &block)
      options[:when] ||= :after
      @state_callbacks ||= CallbackHandler.new
      @state_callbacks.add(from, to, options[:when], &block)
    end

    def state_change_callback(from, to, args, options = {})
      options[:when] ||= :after
      return unless @state_callbacks
      @state_callbacks.get(from, to, options[:when]).try(:call, args)
    end

    def observe_state(state_name)
      class_eval <<-EVAL
        def after_save(subscription)
          state_changes = subscription.changes['#{state_name}']
          from, to = state_changes.try(:first), state_changes.try(:last)
          self.class.state_change_callback(from, to, subscription)
        end

        def before_save(subscription)
          state_changes = subscription.changes['#{state_name}']
          from, to = state_changes.try(:first), state_changes.try(:last)
          self.class.state_change_callback(from, to, subscription, :when => :before)
        end
      EVAL
    end
  #end 
end
