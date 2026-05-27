function scr_endgame_exact_dfs(board, path, depth_left, visited, stats, start_time, time_limit_ms) {
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
    var candidates = [];

    var before_total = scr_count_gems(board);
    var before_clearable = scr_count_clearable_gems(board);

    for (var i = 0; i < array_length(moves); i++) {
        var mv = moves[i];

        if (array_length(path) > 0) {
            var last_mv = path[array_length(path) - 1];

            if (scr_is_reverse_move(last_mv, mv)) {
                continue;
            }
        }

        var next_board = scr_apply_move(board, mv);
        var key = scr_board_key(next_board);

        if (ds_map_exists(visited, key)) {
            continue;
        }

        var after_total = scr_count_gems(next_board);
        var after_clearable = scr_count_clearable_gems(next_board);

        var local_score = 0;

        local_score += (before_total - after_total) * 1000000;
        local_score += (before_clearable - after_clearable) * 500000;
        local_score += scr_endgame_exact_score(next_board);

        var a = board[mv.r1][mv.c1];
        var b = board[mv.r2][mv.c2];

        var is_slide = (a.gem == GEM_EMPTY && b.gem != GEM_EMPTY)
                    || (a.gem != GEM_EMPTY && b.gem == GEM_EMPTY);

        if (is_slide) {
            local_score += 1000;
        }

        if (after_total < before_total) {
            local_score += 3000000;
        }

        array_push(candidates, {
            move: mv,
            board: next_board,
            key: key,
            node_score: local_score
        });
    }

    candidates = scr_exact_take_best_candidates(candidates, 14);

    for (var j = 0; j < array_length(candidates); j++) {
        var cand = candidates[j];

        ds_map_set(visited, cand.key, true);

        var next_path = scr_path_append(path, cand.move);

        var found = scr_endgame_exact_dfs(
            cand.board,
            next_path,
            depth_left - 1,
            visited,
            stats,
            start_time,
            time_limit_ms
        );

        if (!is_undefined(found)) {
            return found;
        }
    }

    return undefined;
}