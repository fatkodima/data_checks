## master (unreleased)

- Add `ensure_equal` check method

    ```ruby
    ensure_equal :featured_projects, to: 100 do
      FeaturedProject.count
    end
    ```

## 0.1.1 (2022-11-26)

- Do not prematurely load `ActiveRecord::Base`

    See https://github.com/rails/rails/issues/46567 for details.

## 0.1.0 (2022-04-21)

- First release
