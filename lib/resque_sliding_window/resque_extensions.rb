require 'resque'
require 'resque_scheduler'
require 'resque/scheduler'
module ResqueSchedulerPatches
  def self.included(base)
    base.extend ClassMethods
    class << base
      alias_method :delayed_timestamp_peek_without_rescue, :delayed_timestamp_peek
      alias_method :delayed_timestamp_peek, :delayed_timestamp_peek_with_rescue
    end
  end

  module ClassMethods
    def next_item_for_timestamp(timestamp)
      key = "delayed:#{timestamp.to_i}"

      item = patched_decode redis.lpop(key)

      # If the list is empty, remove it.
      clean_up_timestamp(key, timestamp)
      item
    end

    def delayed_timestamp_peek_with_rescue(timestamp, start, count)
      delayed_timestamp_peek_without_rescue timestamp, start, count
    rescue Resque::Helpers::DecodeException => e
      []
    end

    def patched_decode(payload)
      decode payload
    rescue Exception => e
    end
  end
end

Resque.send :include, ResqueSchedulerPatches
