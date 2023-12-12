# Payments Tech Assignment

## Architecture and Solution

The solution can be divided into two parts:

* **Municipality support**. This means adding a `Municipality` model (and `municipalities` table) that the `Package` model belongs to (i.e. there is a `packages.municipality_id` foreign key). I have retained the ability to have packages without a municipality so the `municipality_id` is allowed to be null. Also, the unique constraint for the `Package` model is no longer just on the name but instead on the combination of the name and the municipality (i.e. a composite index). This means that for example the Basic package can be present in the table once without a municipality and several times for different municipalities.
* **Improved price history**. I have changed the price history feature so that now we store not only past prices in the `prices` table but also the current price. In addition, each row in the `prices` table now has a price interval represented by the `price_valid_from` and `price_valid_to` columns. This makes it easier to query all prices for a package and makes it obvious how the different prices are laid out in time.

## Disclaimers/Scope/Discussion

* I have not had time to create as many tests as I would have liked. I value tests very highly but I ran out of time.
* Due to time constraints I have not created a migration for the price history from the old to the new schema (i.e. populating the price_valid_from/price_valid_to columns and adding rows for current prices)
* The decision to keep the current prices without municipality may or may not be ideal depending on needs and requirements
* A more normalized data model where a package (such as `Basic`) is only represented once in the database and is then mapped to different municipalities in a separated table (i.e. join model) might have ad some benefits (such as avoiding potential duplication of package metadata). On the other hand such normalization would probably have led to more complex queries (i.e. more joins). It also depends on if packages in different municipalities are fundamentally different packages or if they are not.
