{
	accounts: [.[].postings.[].account] | unique,
	transactions: .
}
