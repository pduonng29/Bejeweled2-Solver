function scr_move_is_empty_slide(board, move) {
    var a = board[move.r1][move.c1];
    var b = board[move.r2][move.c2];

    return (a.gem == GEM_EMPTY && b.gem != GEM_EMPTY)
        || (a.gem != GEM_EMPTY && b.gem == GEM_EMPTY);
}