# Day 2 - Ruby on Rails Lab

## Lab 2A: new_rails

Created a resource manually by hand (Article resource) with:
- Route (config/routes.rb)
- Controller (app/controllers/articles_controller.rb)
- Model (app/models/article.rb)
- Views (app/views/articles/)
- Migration (db/migrate/)

### Active Record Reading Summary

Active Record follows the pattern where each model class maps to a database table and each instance maps to a row. It handles CRUD operations through the model itself, so you dont need to write raw SQL. The Repository Pattern on the other hand separates the data access logic from the business logic using a repository class. Active Record is simpler and faster for small to medium apps while Repository gives you more flexibility for bigger projects with complex data needs.

### Migrations Reading Summary

Migrations in Rails are like version control for the database. Each migration is a Ruby file that describes changes to the schema like creating tables, adding columns, etc. You run them with `rails db:migrate` and can roll them back with `rails db:rollback`. They use timestamps so Rails knows the order to run them in. This is way better than manually changing the database because the whole team stays in sync and you can track changes over time.

## Lab 2B: Fishing Bugs

Found and fixed the following bugs in the fishing-bugs app:

1. **Gemfile source commented out** - The `source "https://rubygems.org"` line was commented out which means bundle install would fail since it doesnt know where to get the gems from.

2. **Wrong route path** - The route had `get "user"` but the endpoint we need to hit is `/users` so I changed it to `get "users"`.

3. **Wrong controller action name** - The controller had a `show` method but the route was mapping to `users#index`. Changed the method name to `index`.

4. **Wrong view folder name** - The views were in `app/views/user/` but Rails looks for views in a folder matching the controller name which is `users`. Renamed the folder to `users`.

5. **Missing ERB output tag** - The view used `<% @users %>` which just evaluates but doesnt display anything. Changed it to `<%= @users %>` so it actually outputs the text.
