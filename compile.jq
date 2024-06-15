.[] |
@text "\(.date) \(.flag) \"\(.payee)\" \"\(.narration)\"
	identifier: \"\(.id)\"
	\(.postings[0].account)	\(.postings[0].amount) NZD
"
# TODO: account for variation in number of postings (There will be more than one in a DOUBLE entry system!!)
