function scr_iddfs_sort_moves(board, moves) {
    var candidates = [];

    for (var i = 0; i < array_length(moves); i++) {
        var mv = moves[i];

        array_push(candidates, {
            move: mv,
            score: scr_iddfs_move_score(board, mv)
        });
    }

    var result = [];

    while (array_length(candidates) > 0) {
        var best_i = 0;
        var best_score = candidates[0].score;

        for (var j = 1; j < array_length(candidates); j++) {
            if (candidates[j].score > best_score) {
                best_score = candidates[j].score;
                best_i = j;
            }
        }

        array_push(result, candidates[best_i].move);
        array_delete(candidates, best_i, 1);
    }

    return result;
}