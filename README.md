# CRAN Index

This API indexes CRAN packages from http://cran.r-project.org/src/contrib/ with their corresponding information.

## Dependencies

ruby 3.0.2
rails 6.1.4
bundler 2.2.26

## Instructions

  ```
  bundle install
  
  rails server
  ```

Go to http://localhost:3000/packages

## Other useful commands

This will reset the database and reload the current schema with all migrations.

  ```
  rake db:reset db:migrate
  ```
 

