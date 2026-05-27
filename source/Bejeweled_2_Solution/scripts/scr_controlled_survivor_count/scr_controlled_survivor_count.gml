function scr_controlled_survivor_count(board, limit_count) {
    var moves = scr_get_legal_moves(board);
    var count = 0;

    for (var i = 0; i < array_length(moves); i++) {
        var mv = moves[i];
        var nb = scr_apply_move(board, mv);

        if (scr_is_solved(nb)) {
            return 999;
        }

        var total = scr_count_gems(nb);

        if (total <= 0) {
            return 999;
        }

        var next_moves = scr_get_legal_moves(nb);

        if (array_length(next_moves) > 0) {
            count += 1;
        }

        if (count >= limit_count) {
            return count;
        }
    }

    return count;
}