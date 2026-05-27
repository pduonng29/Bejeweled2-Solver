function scr_endgame_exact_solve(start_board, max_depth, time_limit_ms) {
    show_debug_message("Trying Endgame Exact Solver...");

    var total_gems = scr_count_gems(start_board);

    if (total_gems > 9) {
        show_debug_message("Endgame Exact skipped: too many gems = " + string(total_gems));
        return undefined;
    }

    if (is_undefined(max_depth) || max_depth <= 0) {
        max_depth = 24;
    }

    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) {
        time_limit_ms = 8000;
    }

    var start_time = get_timer();

    for (var depth_i = 1; depth_i <= max_depth; depth_i++) {
        var visited = ds_map_create();
        ds_map_set(visited, scr_board_key(start_board), true);

        var stats = {
            nodes: 0,
            max_nodes: 9000
        };

        show_debug_message("Exact depth: " + string(depth_i));

        var result = scr_endgame_exact_dfs(
            scr_clone_board(start_board),
            [],
            depth_i,
            visited,
            stats,
            start_time,
            time_limit_ms
        );

        ds_map_destroy(visited);

        if (!is_undefined(result)) {
            show_debug_message("Endgame Exact solved at depth " + string(depth_i));
            show_debug_message("Endgame Exact nodes: " + string(stats.nodes));
            return result;
        }

        var elapsed_ms = (get_timer() - start_time) / 1000;

        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Endgame Exact timeout.");
            return undefined;
        }
    }

    show_debug_message("Endgame Exact failed.");
    return undefined;
}