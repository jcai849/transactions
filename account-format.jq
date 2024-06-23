.items | map_values({
	_account: ._id,
	type: null,
	registry: .connection.name,
	name: .name,
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
