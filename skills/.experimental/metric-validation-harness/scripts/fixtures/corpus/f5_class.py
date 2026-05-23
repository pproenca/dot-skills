class Counter:
    def __init__(self, start=0):
        self.value = start

    def increment(self, by=1):
        self.value += by
        return self.value
