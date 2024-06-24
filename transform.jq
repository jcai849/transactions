def attach_principal_account:
	JOIN(INDEX($accounts[]; ._account); .; ._account; .[1]) + {amount} ;

def attach_accessory_account:
	if .type == "TRANSFER" // .type == "STANDING ORDER" then
		(JOIN(INDEX($accounts[]; .number); .; .meta.other_account; .[1])
		// { type: "Expenses", number: .meta.other_account } )
		+ {amount: -.amount}
	else {}
	# elif .PAYMENT or CREDIT
	# elif LOAN regexes
	# else expenses
	end;

{transaction: ., postings: [attach_principal_account, attach_accessory_account]} #| thin_transactions |  alter_postings | format_to_beancount
