module Resque
  module Plugins
    module SlidingWindow
      extend ActiveSupport::Concern

      module ClassMethods
        def before_schedule_sliding_window(*args)
          WindowSlider.new(self, args).slide
        end

        def after_perform_sliding_window(*args)
          WindowSlider.new(self, args).close
        end
      end
    end
  end
end
