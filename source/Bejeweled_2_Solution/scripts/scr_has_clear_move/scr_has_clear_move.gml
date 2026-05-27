function scr_has_clear_move(board) {
    var before_total = scr_count_gems(board);
    var before_clearable = scr_count_clearable_gems(board);

    var moves = scr_get_legal_moves(board);

    for (var i = 0; i < array_length(moves); i++) {
        var mv = moves[i];

        var nb = scr_apply_move(board, mv);

        if (scr_is_solved(nb)) {
            return true;
        }

        var after_total = scr_count_gems(nb);
        var after_clearable = scr_count_clearable_gems(nb);

        if (after_total < before_total) {
            return true;
        }

        if (after_clearable < before_clearable) {
            return true;
        }
    }

    return false;
}