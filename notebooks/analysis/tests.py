import numpy as np
from scipy.stats import stats


def vargha_delaney_a12(x, y):
    m, n = len(x), len(y)
    rank = stats.rankdata(np.concatenate([x, y]))
    rank_x = rank[:m]
    r1 = np.sum(rank_x)
    u1 = r1-m*(m + 1)/2
    return u1/(m*n)


def a12_label(a12):
    diff = abs(a12 - 0.5)

    if diff < 0.06:
        return "Aucun effet"

    if diff < 0.11:
        return "Effet faible"

    if diff < 0.21:
        return "Effet moyen"

    return "Effet fort"


def cohens_d(x, y):
    diff = x - y

    return diff.mean() / diff.std(ddof=1)