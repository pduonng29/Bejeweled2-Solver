function scr_take_best_nodes(candidates, beam_width) {
    var result = [];

    while (array_length(candidates) > 0 && array_length(result) < beam_width) {
        var best_i = 0;
        var best_node_score = candidates[0].node_score;

        for (var i = 1; i < array_length(candidates); i++) {
            if (candidates[i].node_score > best_node_score) {
                best_node_score = candidates[i].node_score;
                best_i = i;
            }
        }

        array_push(result, candidates[best_i]);
        array_delete(candidates, best_i, 1);
    }

    return result;
}