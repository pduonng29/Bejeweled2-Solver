function scr_tail_dfs_core(board, path, depth_left, visited, stats, start_time, time_limit_ms, no_clear_count) {
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

    var before_total = scr_count_gems(board);
    var before_clearable = scr_count_clearable_gems(board);

    var candidates = [];

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

        var after_total = scr_count_gems(next_board);
        var after_clearable = scr_count_clearable_gems(next_board);

        var next_no_clear = no_clear_count;

        if (after_total >= before_total && after_clearable >= before_clearable) {
            next_no_clear += 1;
        } else {
            next_no_clear = 0;
        }

        if (next_no_clear > 8) {
            continue;
        }

        var key = scr_board_key(next_board);

        if (ds_map_exists(visited, key)) {
            continue;
        }

        var score_value = scr_tail_move_score(board, mv, next_no_clear);

        array_push(candidates, {
            move: mv,
            board: next_board,
            key: key,
            node_score: score_value,
            no_clear: next_no_clear
        });
    }

    candidates = scr_tail_take_best(candidates, 14);

    for (var j = 0; j < array_length(candidates); j++) {
        var cand = candidates[j];

        ds_map_set(visited, cand.key, true);

        var next_path = scr_path_append(path, cand.move);

        var found = scr_tail_dfs_core(
            cand.board,
            next_path,
            depth_left - 1,
            visited,
            stats,
            start_time,
            time_limit_ms,
            cand.no_clear
        );

        ds_map_delete(visited, cand.key);

        if (!is_undefined(found)) {
            return found;
        }
    }

    return undefined;
}