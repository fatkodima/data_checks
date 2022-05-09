# DataChecks

This gem provides a small DSL to check your data for inconsistencies and anomalies.

[![Build Status](https://github.com/fatkodima/data_checks/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/fatkodima/data_checks/actions/workflows/test.yml)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "data_checks"
```

    $ bundle install
    $ bin/rails generate data_checks:install

## Motivation

Making sure that data stays valid is not a trivial task. For simple requirements, like "this column is not null" or "this column is unique", you of course just use the database constraints and that's it. Same goes for type validation or reference integrity.

However, when you want to check for something more complex, then it all changes. Depending on your DBMS, you can use stored procedures, but this is often harder to write, version and maintain.

You could also assume that your data will never get corrupted, and validations directly in the code can do the trick ... but that'd be way too optimistic. Bugs happen all the time, and it's best to plan for the worst.

This gem doesn't aim to replace those tools, but provides something else that could serve a close purpose: *ensure that you work with the data you expect*.

This gem helps you to schedule some verifications on your data and get alerts when something is unexpected.

`data_checks` can help to catch:

* 🐛 **Bugs due to race conditions** (e.g. user accidentally double clicks a button to delete an email and ends up without emails due to a race condition bug in the app)
* 🐛 **Invalid persisted data**
* 🐛 **Unexpected changes in behavior and data** (e.g. too many (too less) of something is created/deleted/imported/enqueued/..., etc)

## Usage

A small DSL is provided to help express predicates and an easy way to configure notifications.

You will be notified when a check starts failing, and when it starts passing again.

### Checking for inconsistencies

For example, we expect every image attachment to have previews in 3 sizes. It is possible, that when a new image was attached, some previews were not generated because of some failure. What we would like to ensure is that no image ends up without a full set of previews. We could write something like:

```ruby
DataChecks.configure do
  ensure_no :users_without_emails, tag: "minutely" do
    User.where.missing(:email_addresses)
  end

  ensure_no :images_without_previews, tag: "hourly" do
    Attachment.images
      .left_joins(:previews)
      .group(:attachment_id)
      .having("COUNT(previews.id) < 3")
  end

  notifier :email,
    from: "production@company.com",
    to: "developer@company.com"
end
```

### Checking for anomalies

This gem can be also used to detect anomalies in the data. For example, you expect to have some number of new orders in the system in some period of time. Otherwise, this can hint at some bug in the order placing system worth investigating.

```ruby
ensure_more :new_orders_per_hour, than: 10, tag: "hourly" do
  Order.where("created_at >= ?", 1.hour.ago).count
end
```

## Configuration

Custom configurations should be placed in a `data_checks.rb` initializer.

```ruby
# config/initializers/data_checks.rb

DataChecks.configure do
  # ...
end
```

### Notifiers

Currently, the following notifiers are supported:

- `:email`: Uses `ActionMailer` to send emails. You can pass it any `ActionMailer` options.
- `:slack`: Sends notifications to Slack. Accepts the following options:
  - `webhook_url`: The webhook url to send notifications to
- `:logger`: Uses `Logger` to output notifications to the log. Accepts the following params:
  - `logdev`: The log device. This is a filename (String) or IO object (typically STDOUT, STDERR, or an open file).
  - `level`: Logging severity threshold (e.g. Logger::INFO)

Each of them accepts a `formatter_class` config to configure the used formatter when generating a notification.

You can create custom notifiers by creating a subclass of [Notifier](https://github.com/fatkodima/data_checks/blob/master/lib/data_checks/notifiers/notifier.rb).

Create a notifier:

```ruby
notifier :email,
  from: "production@company.com",
  to: "developer@company.com"
```

Create multiple notifiers of the same type:

```ruby
notifier "developers",
  type: :email,
  from: "production@company.com",
  to: ["developer1@company.com", "developer2@company.com"]

notifier "tester",
  type: :email,
  from: "production@company.com",
  to: "tester@company.com"

ensure_no :images_without_previews, notify: "developers" do # notify only developers
  # ...
end
```

### Checks

* `ensure_no` will check that the result of a given block is `zero?`, `empty?` or `false`
* `ensure_any` will check that the result of a given block is `> 0`
* `ensure_more` will check that the result of a given block is `>` than a given number or that it contains more than a given number of items
* `ensure_less` will check that the result of a given block is `<` than a given number or that it contains less than a given number of items

```ruby
ensure_no :images_without_previews do
  # ...
end

ensure_any :facebook_logins_per_hour do
  # ...
end

ensure_more :new_orders_per_hour, than: 10 do
  # ...
end
```

### Customizing the error handler

Exceptions raised while a check runs are rescued and information about the error is persisted in the database.

If you want to integrate with an exception monitoring service (e.g. Bugsnag), you can define an error handler:

```ruby
# config/initializers/data_checks.rb

DataChecks.config.error_handler = ->(error, check_context) do
  Bugsnag.notify(error) do |notification|
    notification.add_metadata(:data_checks, check_context)
  end
end
```

The error handler should be a lambda that accepts 2 arguments:

* `error`: The exception that was raised.
* `check_context`: A hash with additional information about the check:
  * `check_name`: The name of the check that errored
  * `ran_at`: The time when the check ran

### Customizing the backtrace cleaner

`DataChecks.config.backtrace_cleaner` can be configured to specify a backtrace cleaner to use when a check errors and the backtrace is cleaned and persisted. An `ActiveSupport::BacktraceCleaner` should be used.

```ruby
# config/initializers/data_checks.rb

cleaner = ActiveSupport::BacktraceCleaner.new
cleaner.add_silencer { |line| line =~ /ignore_this_dir/ }

DataChecks.config.backtrace_cleaner = cleaner
```

If none is specified, the default `Rails.backtrace_cleaner` will be used to clean backtraces.

### Schedule checks

Schedule checks to run (with cron, [Heroku Scheduler](https://elements.heroku.com/addons/scheduler), etc).

```sh
rake data_checks:run_checks TAG="5 minutes"  # run checks with tag="5 minutes"
rake data_checks:run_checks TAG="hourly"     # run checks with tag="hourly"
rake data_checks:run_checks TAG="daily"      # run checks with tag="daily"
rake data_checks:run_checks                  # run all checks
```

Here's what it looks like with cron.

```
*/5 * * * * rake data_checks:run_checks TAG="5 minutes"
0   * * * * rake data_checks:run_checks TAG="hourly"
30  7 * * * rake data_checks:run_checks TAG="daily"
```

You can also manually get a status of all the checks by running:

```sh
rake data_checks:status
```

## Credits

Thanks to [checker_jobs gem](https://github.com/drivy/checker_jobs) for the original idea.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fatkodima/data_checks.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
