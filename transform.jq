def gen_postings: [
	{ account: connect_posting_account,
	  amount: .amount,
	},
	{ account: connect_posted_account,
	  amount: .amount
	}
	];
def gen_payee: "TODO";
def to_ymd: .[:10];

.amount as $amount | .transactions[] | deduplicate |
{ date: .date | to_ymd,
  flag: "!",
  narration: .description,
  postings: gen_postings,
  id: ._id
} | . + { payee: gen_payee } | supplement_postings
