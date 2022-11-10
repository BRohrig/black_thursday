## Black Thursday

Find the [project spec here](http://backend.turing.io/module1/projects/black_thursday/).

Blog;

Most sold item for merchant; 
This method, after much trial and error regarding the starting point, begins by filtering all of the items by which merchant ID they are associated with in the # merch_items_list method. This method is then fed into the # find_merch_iis method to find all of the invoice items associated with the starting merchant ID. Those invoice items are then further filtered against our already built method to find if the associated invoices were paid in full. The remaining invoice_items are sorted using the # max_by enumerable searching for quantity of items to sold to return a single invoice item. Finally this invoice item's item_id is passed as an argument into the item # find_by_id method to return a single item. 

Best item for merchant;
The best item for merchant searches the merchant based off its ID and returns the item that has generated the highest revenue (quantity multiplied by unit price.) To achieve this we have created a helper method paid_invoice_items_by_merchant(merchant_id). This iterates over the invoice_items and finds all that match. It then checks to confirm they are paid for, calling on a previous method invoice_paid_in_full?
If the invoice has been paid in full, we then use max_by to enumerate over the collection. This compares a certain value each time it runs through the collection selecting the largest amount. For the best item for merchant method max by selects the invoice item which has the largest quantity multipled by unit price. 

* What was the most challenging aspect of this project?

  Our expectations weren't  never always what was produced. We had to adapt to a new route with some of our methods to end up at our resuts.

* What was the most exciting aspect of this project?

  Getting to work with 3 people we had never worked before. Learning and developing our knowledge with each other has been a great learning experience. 

* Describe the best choice enumerables you used in your project. Please include file names and line numbers.

  lines 422-429 ends up using a max_by enumerable to get the best item for merchant based on how much sold and how much the price was. Essentially max_by is allowing us to get the item that has the most revenue generated for the merchant.

* Tell us about a module or superclass which helped you re-use code across repository classes. Why did you choose to use a superclass and/or a module?

  We used Reposable for methods such as #update, #next_id, #find_by_id, #delete because these were shared across a lot of our classes and they did the same things.

* Tell us about 1) a unit test and 2) an integration test that you are particularly proud of. Please include file name(s) and line number(s).

For a unit test, in sales_analyst_spec, #average_item_price_for_merchant tested on lines 62-68, we are just testing the sales analyst method. For integrated a test in sales_analyst_spec lines 555-559, we have to be able to test out #sales_anlayst.most_sold_item_for_merchant against #sales_analyst.items.find_by_id, reaching into another class for that find_by_id method. 

* Is there anything else you would like instructors to know?

  We found value in learning how to effectively communicate and split up the work between a small group.

## Questions

1. Anthony: When is the appropriate time to use mocks & stubs?
1. Alastair: Why when moving tests from the reposable to the specific spec file are simplecov numbers not aligning? For example, when running simplecov with tests in reposable 97.2% and then running simplecov with tests in specific spec files outcome: 97.15% [percentages are an example, not literal]
1. Drew: Would there have been a good use case for superclasses in this project?
1. Brady: Is there a limit to the number of helper methods that are preferred? (i.e. the last 2 methods in sales_analyst)
