function scr_is_reverse_move(a, b) {
    if (is_undefined(a)) return false;
    if (is_undefined(b)) return false;

    return a.r1 == b.r2
        && a.c1 == b.c2
        && a.r2 == b.r1
        && a.c2 == b.c1;
}