function scr_iddfs_core(board, path, depth_left, visited, stats, start_time, time_limit_ms) {
    var elapsed_ms = (get_timer() - start_time) / 1000;

    if (elapsed_ms > time_limit_ms) {
        return undefined;
    }

    if (stats.nodes >= stats.max_nodes) {
        return undefined;
    }

    stats.nodes += 1;

    if (scr_is_solved(board)) {
        return path;
    }

    if (depth_left <= 0) {
        return undefined;
    }

    var moves = scr_get_legal_moves(board);

    if (array_length(moves) <= 0) {
        return undefined;
    }

    moves = scr_iddfs_sort_moves(board, moves);

    for (var i = 0; i < array_length(moves); i++) {
        var mv = moves[i];

        if (array_length(path) > 0) {
            var last_mv = path[array_length(path) - 1];

            if (scr_is_reverse_move(last_mv, mv)) {
                continue;
            }
        }

        var next_board = scr_apply_move(board, mv);

        if (scr_is_solved(next_board)) {
            return scr_path_append(path, mv);
        }

        var next_key = scr_board_key(next_board);

        if (ds_map_exists(visited, next_key)) {
            continue;
        }

        var next_moves = scr_get_legal_moves(next_board);

        if (scr_count_gems(next_board) > 0 && array_length(next_moves) <= 0) {
            continue;
        }

        ds_map_set(visited, next_key, true);

        var next_path = scr_path_append(path, mv);

        var found = scr_iddfs_core(
            next_board,
            next_path,
            depth_left - 1,
            visited,
            stats,
            start_time,
            time_limit_ms
        );

        ds_map_delete(visited, next_key);

        if (!is_undefined(found)) {
            return found;
        }
    }

    return undefined;
}