function scr_dfs(board, visited, depth, max_depth) {
    if (scr_is_solved(board)) {
        return [];
    }

    if (depth >= max_depth) {
        return undefined;
    }

    var key = scr_board_key(board);

    if (ds_map_exists(visited, key)) {
        return undefined;
    }

    ds_map_set(visited, key, true);

    var moves = scr_get_best_ordered_moves(board);

    for (var i = 0; i < array_length(moves); i++) {
        var mv = moves[i];

        var next_board = scr_apply_move(board, mv);

        var sub_solution = scr_dfs(next_board, visited, depth + 1, max_depth);

        if (!is_undefined(sub_solution)) {
            var result = [];

            array_push(result, mv);

            for (var j = 0; j < array_length(sub_solution); j++) {
                array_push(result, sub_solution[j]);
            }

            return result;
        }
    }

    return undefined;
}