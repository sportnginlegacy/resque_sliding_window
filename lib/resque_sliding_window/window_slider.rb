module ResqueSlidingWindow
  class WindowSlider
    extend Forwardable

    attr_accessor :klass
    attr_accessor :args

    def_delegators :Resque, :job_to_hash, :encode, :redis, :remove_delayed_job_from_timestamp

    def initialize(klass, args)
      self.klass = klass
      self.args = args
    end

    def slide
      if first?
        mark_first
      elsif should_requeue?
        requeue
      else
        false
      end
    end

    def close
      redis.del(slide_key)
    end

    private

    def first?
      !on_queue?
    end

    def mark_first
      mark_time
    end

    def requeue
      matching_delayed.each do |key, _|
        remove_delayed_job_from_timestamp(key_to_timestamp(key), klass, *args)
      end
      true
    end

    def should_requeue?
      !maxed_out?
    end

    def matching_delayed
      delayed_key_values.select { |_, value| value == search }
    end

    def search
      encode(job_to_hash klass, args)
    end

    def on_queue?
      matching_delayed.count > 0
    end

    def max_time
      klass.respond_to?(:max_time) ? klass.public_send(:max_time) : 1.minute
    end

    def maxed_out?
      (redis.get(slide_key).to_i + max_time) <= Time.now.utc.to_i
    end

    def slide_key
      "sliding:#{klass.name}:#{keyify(args)}:count"
    end

    def mark_time
      redis.set(slide_key, Time.now.utc.to_i)
    end

    def keyify(args)
      "(#{args.map { |arg|
        if arg.is_a?(Array)
          keyify(arg)
        elsif arg.respond_to?(:to_a) && !(arg.is_a?(String) || arg.is_a?(Symbol) || arg.is_a?(Numeric))
          keyify(arg.to_a)
        else
          if arg.respond_to?(:to_key)
            arg.to_key
          else
            arg.to_s
          end
        end
      }.join(",").gsub(/\s/,"")})"
    end

    def key_to_timestamp(key)
      key.to_s.gsub(/delayed:/, "").to_i
    end

    def timestamp_to_key(timestamp)
      "delayed:#{timestamp}"
    end

    def delayed_timestamps
      redis.zrange(:delayed_queue_schedule, 0,-1)
    end

    def get(key)
      redis.rpop(key).tap { |val|
        redis.rpush(key, val)
      }
    end

    def delayed_key_values
      delayed_timestamps.inject({}) do |hash, timestamp|
        hash[timestamp_to_key(timestamp)] = get(timestamp_to_key(timestamp))
        hash
      end
    end
  end
end
