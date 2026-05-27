function scr_get_smart_ordered_moves(board, prev_move, max_take) {
    var raw_moves = scr_get_legal_moves(board);
    var scored = [];

    for (var i = 0; i < array_length(raw_moves); i++) {
        var mv = raw_moves[i];

        if (scr_is_reverse_move(prev_move, mv)) {
            continue;
        }

        var mv_score = scr_smart_score_move(board, mv);

        if (mv_score > 0) {
            array_push(scored, {
                move: mv,
                node_score: mv_score
            });
        }
    }

    var result = [];

    while (array_length(scored) > 0 && array_length(result) < max_take) {
        var best_i = 0;
        var best_node_score = scored[0].node_score;

        for (var j = 1; j < array_length(scored); j++) {
            if (scored[j].node_score > best_node_score) {
                best_node_score = scored[j].node_score;
                best_i = j;
            }
        }

        array_push(result, scored[best_i].move);
        array_delete(scored, best_i, 1);
    }

    return result;
}