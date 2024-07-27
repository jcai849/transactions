def ymd: .[:10];
def transaction_directive:
        "\(.transaction.date | ymd) "
        + "* "
        + "\"\(.transaction.description)\"\n"
        + "\tidentifier: \"\(.transaction._id)\"\n"
        + (.postings
          | map("\t\(.account | join(":")) \(.amount) NZD\n")
          | add);

def open_directive:
	"2000-01-01 open \(join(":")) NZD";

(
	"option \"operating_currency\" \"NZD\"",
	(.accounts.[] | open_directive),
	(.transactions.[] | transaction_directive)
)
