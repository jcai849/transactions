def attach_principal_account:
	JOIN(INDEX($accounts[]; ._account); .;
	 ._account; .[1])
	+ {amount};

def attach_other_account(account_number):
	JOIN(INDEX($accounts[]; .number); .;
         account_number; .[1]);

def asb_loan_account_from_description:
	match("([[:digit:]-]{18}) ([[:digit:]]{3})").captures? |
	.[0] |= .string |
	.[1] |= (.string | tonumber | tostring) |
	.[0] + " " + .[1];

def attach_expense_account:
	{type: "Expenses"} +
	if .category.groups.personal_finance.name then
		{ group: .category.groups.personal_finance.name,
		  subgroup: .category.name,
		  name: .merchant.name }
	else
		{ group: "Uncategorised" }
	end
	+ {amount: -.amount};

def attach_fee_account:
	{
		type: "Expenses", group: "Bank",
		name: "Fee", amount: -.amount
	};

def attach_interest_account:
	attach_principal_account | {
		type: "Expenses", group, name, number,
		holder, currency, amount: -.amount
	};

def attach_debit_account:
	if ([.type == ("TRANSFER", "PAYMENT", "STANDING ORDER", "CREDIT")] | any) then
		if (.meta | has("other_account")) then
			attach_other_account(.meta.other_account)
		else null end // attach_expense_account
	elif .type == "FEE" then attach_fee_account
	elif .type == "LOAN" then
		attach_other_account(.description | asb_loan_account_from_description)
	elif .type == "INTEREST" then attach_interest_account
	elif ([.type == ("EFTPOS", "DEBIT", "DIRECT DEBIT")] | any) then
		attach_expense_account
	else halt_error
	end
	+ {amount: -.amount};

def attach_uncategorised_income_account:
	{ type: "Income", group: "Uncategorised", amount};

def attach_credit_account:
	# returning duplicates of debit accounts as empty, for future thinning
	if ([.type == ("TRANSFER", "PAYMENT", "STANDING ORDER", "CREDIT")] | any) then
		if (.meta | has("other_account") | not)
		or (attach_other_account(.meta.other_account) == null) then
			attach_uncategorised_income_account
		else empty
		end
	elif .type == "EFTPOS" then
			attach_uncategorised_income_account
	elif .type == "LOAN" then empty
	elif .type == "INTEREST" then
		attach_principal_account |{
			type: "Income", group: "Interest",
			subgroup: .group, name, amount: -.amount}
	else halt_error
	end;

def attach_accessory_account:
	if .amount < 0 then
		attach_debit_account
	elif .amount > 0 then
		attach_credit_account
	else empty
	end;

def thin_transactions:
	if .postings | length < 2 then empty end;

{transaction: ., postings: [attach_principal_account, attach_accessory_account]} | thin_transactions
#  alter_postings | format_to_beancount
