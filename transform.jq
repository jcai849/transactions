def attach_principal_account:
	JOIN(INDEX($accounts[]; ._account); .; ._account; .[1])
	+ {amount};

def attach_other_account(account_number):
	JOIN(INDEX($accounts[]; .number); .; account_number; .[1]);

def asb_loan_account_from_description:
	match("([[:digit:]-]{18}) ([[:digit:]]{3})").captures? |
	.[0] |= .string |
	.[1] |= (.string | tonumber | tostring) |
	.[0] + " " + .[1];

def attach_debit_account:
	if ([.type == ("TRANSFER", "PAYMENT", "STANDING ORDER")] | any) then
		(attach_other_account(.meta.other_account)
		 // { type: "Expenses", number: .meta.other_account })
		+ {amount: -.amount}
	elif .type == "LOAN" then
		attach_other_account(.description | asb_loan_account_from_description)
		+ {amount: -.amount}
	# elif .type == EFTPOS,DEBIT,DIRECT DEBIT
	else empty
	end;

def attach_credit_account:
	empty;

def attach_accessory_account:
	if .amount < 0 then
		attach_debit_account
	elif .amount > 0 then
		attach_credit_account
	else empty
	end;

{transaction: ., postings: [attach_principal_account, attach_accessory_account]}
#| thin_transactions |  alter_postings | format_to_beancount
