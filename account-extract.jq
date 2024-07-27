.items | map_values({
	_account: ._id,
	type: null,
	group: .connection.name,
	name,
	balance: .balance.current,
	number: .formatted_account,
	category: .type,
	holder: .meta.holder,
	currency: .balance.currency
} |
.type = 
	if .category == "LOAN" then
		"Liabilities"
	elif .category == "TAX" then
		"Expenses"
	else
		"Assets"
	end |
del(.category)
)
