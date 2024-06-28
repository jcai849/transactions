def ymd: .[:10];
def make_account:
        [.type?, .group?, .subgroup?, .name?] | map(select(.))
	| map((.[0:1] | ascii_upcase) + .[1:]
		| gsub(" "; "-")
		| gsub(","; "-")
		| gsub("&"; "-")
		| gsub("'"; "")
		| gsub("\\("; "")
		| gsub("\\)"; "")
	)
        | join(":");
def format_as_beancount:
        "\(.transaction.date | ymd) "
        + "* "
        + "\"\(.transaction.description)\"\n"
        + "\tidentifier: \"\(.transaction._id)\"\n"
        + (.postings
          | map("\t\(make_account) \(.amount) NZD\n")
          | add);

format_as_beancount
