function scr_iddfs_move_score(board, mv) {
    var before_total = scr_count_gems(board);
    var before_clearable = scr_count_clearable_gems(board);
    var before_specials = scr_count_specials(board);

    var next_board = scr_apply_move(board, mv);

    var after_total = scr_count_gems(next_board);
    var after_clearable = scr_count_clearable_gems(next_board);
    var after_specials = scr_count_specials(next_board);

    var next_moves = scr_get_legal_moves(next_board);
    var next_legal_count = array_length(next_moves);

    var score_value = 0;

    if (after_total == 0) {
        score_value += 999999999;
    }

    score_value += (before_total - after_total) * 5000000;
    score_value += (before_clearable - after_clearable) * 1500000;

    if (after_total > 0 && next_legal_count <= 0) {
        score_value -= 99999999;
    }

    score_value += next_legal_count * 800000;

    if (after_total <= 12) {
        score_value += next_legal_count * 1200000;
    }

    if (after_total <= 8) {
        score_value += next_legal_count * 2000000;
    }

    if (after_specials < before_specials) {
        score_value += 1000000;
    }

    var a = board[mv.r1][mv.c1];
    var b = board[mv.r2][mv.c2];

    if (a.pwr == 1 || b.pwr == 1) {
        score_value += 500000;
    }

    if (a.gem == GEM_HYPER || b.gem == GEM_HYPER) {
        score_value += 1000000;
    }

    return score_value;
}