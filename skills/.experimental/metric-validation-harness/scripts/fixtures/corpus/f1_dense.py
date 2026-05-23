result = sum(a * b + c for a, b, c in zip(xs, ys, zs)) if xs and ys else (lambda n: n * 2)(0)
