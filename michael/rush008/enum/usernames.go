package main

func GenerateLetters(length int) []string {
	var results []string
	letters := []rune("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

	var helper func(prefix string, depth int)
	helper = func(prefix string, depth int) {
		if depth == 0 {
			results = append(results, prefix)
			return
		}
		for _, l := range letters {
			helper(prefix+string(l), depth-1)
		}
	}

	helper("", length)
	return results
}

func GenerateDigits(length int) []string {
	var results []string
	firstDigits := []rune("123456789")
	otherDigits := []rune("0123456789")

	var helper func(prefix string, depth int)
	helper = func(prefix string, depth int) {
		if depth == 0 {
			results = append(results, prefix)
			return
		}
		var set []rune
		if len(prefix) == 0 {
			set = firstDigits
		} else {
			set = otherDigits
		}
		for _, d := range set {
			helper(prefix+string(d), depth-1)
		}
	}

	helper("", length)
	return results
}
