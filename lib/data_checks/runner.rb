# frozen_string_literal: true

module DataChecks
  class Runner
    def run_checks(tag: nil)
      checks = DataChecks.config.checks
      checks = checks.select { |check| check.tag == tag.to_s } if tag

      checks.each do |check|
        run_one(check)
      end
    end

    def run_check(name)
      checks = DataChecks.config.checks
      check = checks.find { |c| c.name == name.to_s }
      raise "Check #{name} not found" unless check

      run_one(check)
    end

    private
      def run_one(check)
        previous_check_run = check.check_run
        previous_status = previous_check_run&.status

        check_result = check.run

        if check_result.error?
          check_run = mark_check_as_errored(check, check_result.error)

          check_context = { check_name: check.name, run_at: Time.current }
          handle_exception(check_result.error, context: check_context)
        else
          check_run = mark_check_as_completed(check, check_result.passing?)
        end

        # Notify if not passing or the status changed
        if !check_result.passing? ||
           (previous_status && previous_status != check_run.status)
          notify(check.notifiers, check_result)
        end

        check_result
      end

      def mark_check_as_errored(check, error)
        backtrace_cleaner = DataChecks.config.backtrace_cleaner

        run = check.check_run || CheckRun.new(name: check.name)
        run.status = :error
        run.error_class = error.class.name
        run.error_message = error.message
        run.backtrace = backtrace_cleaner ? backtrace_cleaner.clean(error.backtrace) : error.backtrace
        run.last_run_at = Time.current
        run.save!
        run
      end

      def mark_check_as_completed(check, passing)
        run = check.check_run || CheckRun.new(name: check.name)
        run.status = (passing ? :passing : :failing)
        run.error_class = nil
        run.error_message = nil
        run.backtrace = nil
        run.last_run_at = Time.current
        run.save!
        run
      end

      def notify(notifiers, check_result)
        notifiers.each do |notifier|
          safely { notifier.notify(check_result) }
        end
      end

      def safely
        yield
      rescue Exception => e # rubocop:disable Lint/RescueException
        handle_exception(e)
      end

      def handle_exception(exception, context: {})
        if (error_handler = DataChecks.config.error_handler)
          error_handler.call(exception, context)
        else
          raise exception
        end
      end
  end
end
