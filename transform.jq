def gen_postings: [
	{ account: "TODO",
	  amount: .amount }
	]; # this will have to vary (account for this!)
def gen_payee: "TODO";
def to_ymd: .[:10];

[.transactions[] |
{ date: .date | to_ymd,
  flag: "!",
  payee: gen_payee,
  narration: .description,
  postings: gen_postings,
  id: ._id
}]
