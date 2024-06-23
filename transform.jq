def attach_principal_account:
	JOIN(INDEX($accounts[]; ._account); .; ._account;
		{transaction: .[0], principal_account: .[1]}) |
	.principal_account += {amount: .transaction.amount};
def attach_accessory_account:
	if .transaction.type == "TRANSFER" then
		JOIN(INDEX($accounts[]; .account_number); .;
		.transaction.meta.other_account; .[0] + {accessory_account: .[1]})
	else
		. + {accessory_account: "Unknown"}
	end;

attach_principal_account #|
#attach_accessory_account #| thin_transactions | gen_postings | alter_postings | format_to_beancount

