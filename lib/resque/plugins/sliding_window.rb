module Resque
  module Plugins
    module SlidingWindow
      def before_schedule_sliding_window(*args)
        ResqueSlidingWindow::WindowSlider.new(self, args).slide
      end

      def after_perform_sliding_window(*args)
        ResqueSlidingWindow::WindowSlider.new(self, args).close
      end
    end
  end
end
