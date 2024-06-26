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
	if .merchant then
		{ group: .category.groups.personal_finance.name,
		  subgroup: .category.name,
		  name: .merchant.name }
	else
		{ group: "Uncategorised",
		  name: .description }
	end
	+ {amount: -.amount};

def attach_debit_account:
	if ([.type == ("TRANSFER", "PAYMENT", "STANDING ORDER", "CREDIT")] | any) then
		attach_other_account(.meta.other_account) //
		attach_expense_account
	elif .type == "LOAN" then
		attach_other_account(.description | asb_loan_account_from_description)
	elif ([.type == ("EFTPOS", "DEBIT", "DIRECT DEBIT")] | any) then
		attach_expense_account
	else halt_error
	end
	+ {amount: -.amount};

def attach_credit_account:
	.;

def attach_accessory_account:
	if .amount < 0 then
		attach_debit_account
	elif .amount > 0 then
		attach_credit_account
	else empty
	end;

{transaction: ., postings: [attach_principal_account, attach_accessory_account]} #| select(.transaction.amount > 0)
#| thin_transactions |  alter_postings | format_to_beancount
