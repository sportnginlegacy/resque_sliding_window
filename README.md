# ResqueSlidingWindow

Want a sliding window for debouncing bursty Resque events? Here it is.

## Installation

Add this line to your application's Gemfile:

    gem 'resque_sliding_window'
    gem 'resque-scheduler', require: 'resque_scheduler', git: "https://github.com/jonhyman/resque-scheduler.git" # prefered repo

And then execute:

    $ bundle

## Usage

```ruby
module Jobs
  class Publish
    include Resque::Plugins::SlidingWindow

    @queue = :low

    def self.perform(id)
      # Crazy stuff
    end
  end
end

Resque.enqueue_in(30, Jobs::Publish, id)
```

This will put a job in a delayed queue for 30 seconds. If a similar job is entered (same args, same klass),
it will be deleted in favor of the new 30-second job. However, it can only be
pushed off for a 1m 30s from its initial queue-time before it force runs one. When it forces
one through, others will not be run.

Default `max_time` is 1m and 30s. To change this:

```ruby
module Jobs
  class Publish
    include Resque::Plugins::SlidingWindow

    @queue = :low

    def self.max_time
      30.minutes
    end

    def self.perform(id)
      # Crazy stuff
    end
  end
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
