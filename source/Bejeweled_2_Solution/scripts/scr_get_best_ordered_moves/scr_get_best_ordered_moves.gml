function scr_get_best_ordered_moves(board) {
    var moves = scr_get_legal_moves(board);
    var ordered = [];

    while (array_length(moves) > 0) {
        var best_i = 0;
        var best_score = -999999;

        for (var i = 0; i < array_length(moves); i++) {
            var move_score = scr_score_move(board, moves[i]);

            if (move_score > best_score) {
                best_score = move_score;
                best_i = i;
            }
        }

        array_push(ordered, moves[best_i]);
        array_delete(moves, best_i, 1);
    }

    return ordered;
}