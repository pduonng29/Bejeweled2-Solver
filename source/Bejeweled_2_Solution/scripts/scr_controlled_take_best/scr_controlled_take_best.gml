function scr_controlled_take_best(nodes, limit_count) {
    var result = [];

    while (array_length(result) < limit_count && array_length(nodes) > 0) {
        var best_i = 0;
        var best_score = nodes[0].node_score;

        for (var i = 1; i < array_length(nodes); i++) {
            if (nodes[i].node_score > best_score) {
                best_score = nodes[i].node_score;
                best_i = i;
            }
        }

        array_push(result, nodes[best_i]);
        array_delete(nodes, best_i, 1);
    }

    return result;
}