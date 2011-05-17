module StateCallbacks
  class CallbackHandler < Hash
    def add(from, to, &block)
      self[[from.to_s, to.to_s]] = block.to_proc
    end

    def get(from, to)
      self.find { |(k,v)|
        from.to_s == k[0].to_s && to.to_s == k[1].to_s
      }.try(:last)
    end
  end

  def on(from, to, &block)
    @state_callbacks ||= CallbackHandler.new
    @state_callbacks.add(from, to, &block)
  end

  def state_change_callback(from, to, args)
    return unless @state_callbacks
    @state_callbacks.get(from, to).try(:call, args)
  end
end
