# Little Shop

## Summary

Little Shop is an e-commerce web application that has visitor, user, merchant, and admin authorization levels. Merchants can individually fulfill separate items in aggregate orders that users place with the store. Visitors can browse, add items to carts, and see statistics data, but cannot checkout without registering or logging in. Admins have access to almost all functionality that
users and merchants do, and they can also enable and disable users and merchants.

## Setup

If you would like to run this app yourself, this repo can be forked and then cloned by clicking on the "clone or download" button, then following cloning instructions. After forking and cloning, run the following commands in your terminal while in the project directory:

-- `bundle install`

-- `rake db:{drop,create,migrate,seed}'``

-- `rails s`

## Prerequisites

Rails 5.1
A terminal
Github Account

## How To Run The Test Suite

To run the test suite, simply run the following command in your terminal:

`rspec`

If you'd like to run a specific test or directory of tests, you can run commands similar to the following:

`rspec spec/models/` this will run all model tests
`rspec spec/models/item_spec.rb` this will run all item model tests
`rspec spec/models/item_spec.rb:31` this will run a specific item model test.

## Contributors
Ian Douglas wrote the vast majority of this app, while Bradley Niedt added slugs to users and items, as well as bulk discounts.
