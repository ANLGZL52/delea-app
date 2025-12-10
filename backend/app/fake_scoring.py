import random

def fake_score():
    return {
        "pronunciation": random.randint(60, 90),
        "fluency": random.randint(50, 85),
        "grammar": random.randint(55, 80),
        "lexical": random.randint(50, 85),
        "task": random.randint(60, 90),
        "overall": random.randint(55, 90)
    }
