def signed_total(items):
    total = 0
    for item in items:
        if item > 0:
            total += item
        else:
            total -= item
    return total
