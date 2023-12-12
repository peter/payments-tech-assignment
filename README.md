# Payments Tech Assignment

## Disclaimers/Scope/Discussion

* Application structure
* Data integrity
* Testing
* Design choices and their advantages and disadvantages

## Architecture and Solution

* Added a `Municipality` model with a unique/indexed `name` field
* Added the `belongs_to :municipality` relationship in `Package` model (i.e. a `municipality_id` foreign key in the `packages` table)
