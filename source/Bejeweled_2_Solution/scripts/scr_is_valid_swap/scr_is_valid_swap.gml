function scr_is_valid_swap(board, r1, c1, r2, c2) {
    if (!scr_inside_board(r1, c1)) return false;
    if (!scr_inside_board(r2, c2)) return false;

    var mv = {
        r1: r1,
        c1: c1,
        r2: r2,
        c2: c2
    };

    return scr_is_real_legal_move(board, mv);
}
