def attach_principal_account:
	JOIN(INDEX($accounts[]; ._account); .; ._account;
		{transaction: .[0], postings: [.[1]]}) |
	.postings[0] += {amount: .transaction.amount};
def add_postings:
	if .transaction.type == "TRANSFER" then # see TODO, match with STANDIN ORDER as well
		JOIN(INDEX($accounts[]; .number); .;
		     .transaction.meta.other_account;
		     {
		       transaction: .[0].transaction,
		       postings: (.[0].postings + [.[1]])
		     }) |
		     .postings[1] += {amount: -.transaction.amount}
	# elif .PAYMENT or CREDIT
	# elif LOAN regexes
	# else expenses
	end;

attach_principal_account |
add_postings #| thin_transactions |  alter_postings | format_to_beancount

