function scr_small_board_move_score(board, mv) {
    var before_total = scr_count_gems(board);
    var before_clearable = scr_count_clearable_gems(board);
    var next_board = scr_apply_move(board, mv);
    var after_total = scr_count_gems(next_board);
    var after_clearable = scr_count_clearable_gems(next_board);
    var after_legal = array_length(scr_get_legal_moves(next_board));

    var score_value = 0;
    score_value += (before_total - after_total) * 6000000;
    score_value += (before_clearable - after_clearable) * 2000000;
    score_value += after_legal * 500000;
    if (after_total == 0) score_value += 99999999;
    if (after_total < before_total) score_value += 5000000;
    if (after_total <= 6) score_value += 2000000;
    if (after_legal <= 1 && after_total > 0) score_value -= 4000000;

    var a = board[mv.r1][mv.c1];
    var b = board[mv.r2][mv.c2];
    if (a.pwr == 1 || b.pwr == 1) score_value += 1500000;
    if (a.gem == GEM_HYPER || b.gem == GEM_HYPER) score_value += 2000000;
    return score_value;
}

function scr_small_board_take_best(candidates, limit_count) {
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

function scr_small_board_dfs_core(board, path, depth_left, visited, stats, start_time, time_limit_ms, branch_limit) {
    var elapsed_ms = (get_timer() - start_time) / 1000;
    if (elapsed_ms > time_limit_ms) return undefined;
    if (stats.nodes >= stats.max_nodes) return undefined;
    stats.nodes += 1;

    if (scr_is_solved(board)) return path;
    if (depth_left <= 0) return undefined;

    var moves = scr_get_legal_moves(board);
    if (array_length(moves) <= 0) return undefined;

    var candidates = [];
    for (var i = 0; i < array_length(moves); i++) {
        var mv = moves[i];
        if (array_length(path) > 0) {
            var last_mv = path[array_length(path) - 1];
            if (scr_is_reverse_move(last_mv, mv)) continue;
        }
        var next_board = scr_apply_move(board, mv);
        if (scr_is_solved(next_board)) return scr_path_append(path, mv);
        var key = scr_board_key(next_board);
        if (ds_map_exists(visited, key)) continue;
        array_push(candidates, {
            move: mv,
            board: next_board,
            key: key,
            node_score: scr_small_board_move_score(board, mv)
        });
    }

    candidates = scr_small_board_take_best(candidates, branch_limit);

    for (var j = 0; j < array_length(candidates); j++) {
        var cand = candidates[j];
        ds_map_set(visited, cand.key, true);
        var next_path = scr_path_append(path, cand.move);
        var found = scr_small_board_dfs_core(cand.board, next_path, depth_left - 1, visited, stats, start_time, time_limit_ms, branch_limit);
        if (!is_undefined(found)) return found;
    }

    return undefined;
}

function scr_small_board_bfs_solve(start_board, max_depth, max_nodes, time_limit_ms) {
    show_debug_message("Trying Small Board DFS Solver v18 RAM-CAPPED...");

    var total_start = scr_count_gems(start_board);
    if (total_start > 10) {
        show_debug_message("Small DFS skipped: too many gems = " + string(total_start));
        return undefined;
    }

    if (is_undefined(max_depth) || max_depth <= 0) max_depth = 16;
    if (max_depth > 20) max_depth = 20;

    if (is_undefined(max_nodes) || max_nodes <= 0) max_nodes = 7000;
    if (max_nodes > 10000) max_nodes = 10000;

    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) time_limit_ms = 2500;
    if (time_limit_ms > 4000) time_limit_ms = 4000;

    var start_time = get_timer();
    var branch_limit = 5;
    if (total_start <= 8) branch_limit = 6;
    if (total_start <= 5) branch_limit = 8;

    for (var depth_i = 1; depth_i <= max_depth; depth_i++) {
        var visited = ds_map_create();
        ds_map_set(visited, scr_board_key(start_board), true);
        var stats = { nodes: 0, max_nodes: max_nodes };

        var result = scr_small_board_dfs_core(scr_clone_board(start_board), [], depth_i, visited, stats, start_time, time_limit_ms, branch_limit);
        ds_map_destroy(visited);

        if (!is_undefined(result)) {
            show_debug_message("Small DFS v18 solved at depth " + string(depth_i) + " | nodes=" + string(stats.nodes));
            return result;
        }

        var elapsed_ms = (get_timer() - start_time) / 1000;
        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Small DFS v18 timeout.");
            return undefined;
        }
        if (stats.nodes >= max_nodes) {
            show_debug_message("Small DFS v18 node cap.");
            return undefined;
        }
    }

    show_debug_message("Small DFS v18 failed.");
    return undefined;
}
