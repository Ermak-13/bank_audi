BANK AUDI
=========

Bank Audi is the largest bank of Lebanon. This gem help to integrate with bank system
(Audi Virtual Payment Client. It is similiar to PayPal)

MAIN STEPS
----------

1. Merchant Form Submission
2. Pre-Payment Process
3. Payment Process
4. Merchant Response Code


BASIC MOMENTS
-------------

1. Request create `BankAudi::Request.new(attributes)`.
2. Attributes as secret_code, access_code, merchant, url (where you create request) you
should set in config/bank_audi.yml
3. You should set :merchant_txn_ref, order_info, amount  & return_url
4. You can update update request `request.attributes = {}; request.amount = 100;`
5. Get request url (with params) `request.full_url`
6. Response create `BankAudi::Response.new(attributes)`
7. Check valid of response `response.valid?` (The invalid reason are bad secure hash & bad response code)
8. You can get messafe of errors if your object (request or response) is invalid? `object.errors`
