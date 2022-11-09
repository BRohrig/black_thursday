## Black Thursday

Find the [project spec here](http://backend.turing.io/module1/projects/black_thursday/).

Blog;

Most sold item for merchant;
This method, after much trial and error regarding the starting point, begins by filtering all of the items by which merchant ID they are associated with in the # merch_items_list method. This method is then fed into the # find_merch_iis method to find all of the invoice items associated with the starting merchant ID. Those invoice items are then further filtered against our already built method to find if the associated invoices were paid in full. The remaining invoice_items are sorted using the # max_by enumerable searching for quantity of items to sold to return a single invoice item. Finally this invoice item's item_id is passed as an argument into the item # find_by_id method to return a single item. 

Best item for merchant;
The best item for merchant searches the merchant based off its ID and returns the item that has generated the highest revenue (quantity multiplied by unit price.) To achieve this we have created a helper method paid_invoice_items_by_merchant(merchant_id). This iterates over the invoice_items and finds all for that merchant which are paid in full.  To determine if an invoice is paid in full, we use the invoice_paid_in_full? method, which searches transactions and returns true if an invoice has at least one successful payment.  If the invoice has been paid in full, we then use max_by to enumerate over the collection. This compares a certain value each time it runs through the collection selecting the largest amount.  For the best item for merchant method max by selects the invoice item which has the largest quantity multipled by unit price. 
