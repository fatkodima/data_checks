## master (unreleased)

## 0.3.0 (2024-08-10)

- Drop support for older activerecord and ruby versions

## 0.2.0 (2023-11-09)

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
