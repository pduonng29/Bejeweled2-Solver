function scr_exact_take_best_candidates(candidates, limit_count) {
    var result = [];

    while (array_length(result) < limit_count && array_length(candidates) > 0) {
        var best_i = 0;
        var best_score_value = candidates[0].node_score;

        for (var i = 1; i < array_length(candidates); i++) {
            if (candidates[i].node_score > best_score_value) {
                best_score_value = candidates[i].node_score;
                best_i = i;
            }
        }

        array_push(result, candidates[best_i]);
        array_delete(candidates, best_i, 1);
    }

    return result;
}