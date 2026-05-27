function scr_dls_smart(board, path, seen, d, limit, start_time, time_limit_ms, prev_move, max_branch, ctrl) {
    var elapsed_ms = (get_timer() - start_time) / 1000;

    if (elapsed_ms > time_limit_ms) {
        return undefined;
    }

    ctrl.nodes += 1;

    if (ctrl.nodes > ctrl.max_nodes) {
        return undefined;
    }

    if (scr_is_solved(board)) {
        return path;
    }

    if (d >= limit) {
        return undefined;
    }

    var moves = scr_get_fast_ordered_moves(board, prev_move, max_branch);

    for (var i = 0; i < array_length(moves); i++) {
        var mv = moves[i];

        var next_board = scr_apply_move(board, mv);
        var key = scr_board_key(next_board);

        if (ds_map_exists(seen, key)) {
            continue;
        }

        ds_map_set(seen, key, true);

        var next_path = scr_path_append(path, mv);

        var result = scr_dls_smart(
            next_board,
            next_path,
            seen,
            d + 1,
            limit,
            start_time,
            time_limit_ms,
            mv,
            max_branch,
            ctrl
        );

        if (!is_undefined(result)) {
            return result;
        }

        ds_map_delete(seen, key);
    }

    return undefined;
}