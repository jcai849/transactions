{
	start: now | strftime("%Y-%m-%d"),
	end: (now-60*60*24*(env.DAYS_PRIOR|tonumber)) | strftime("%Y-%m-%d")
}
