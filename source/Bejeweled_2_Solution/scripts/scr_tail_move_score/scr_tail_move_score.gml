function scr_tail_move_score(board, mv, no_clear_count) {
    var before_total = scr_count_gems(board);
    var before_clearable = scr_count_clearable_gems(board);
    var before_special = scr_count_specials(board);

    var next_board = scr_apply_move(board, mv);

    var after_total = scr_count_gems(next_board);
    var after_clearable = scr_count_clearable_gems(next_board);
    var after_special = scr_count_specials(next_board);
    var after_legal = array_length(scr_get_legal_moves(next_board));

    var score_value = 0;

    if (after_total == 0) {
        return 999999999;
    }

    score_value += (before_total - after_total) * 12000000;
    score_value += (before_clearable - after_clearable) * 5000000;
    score_value += after_legal * 1000000;

    if (after_total < before_total) {
        score_value += 10000000;
    }

    if (after_total <= 3) {
        score_value += 3000000;
    }

    if (after_special < before_special) {
        score_value += 2000000;
    }

    if (after_total > 0 && after_legal <= 0) {
        score_value -= 50000000;
    }

    score_value -= no_clear_count * 1000000;

    return score_value;
}