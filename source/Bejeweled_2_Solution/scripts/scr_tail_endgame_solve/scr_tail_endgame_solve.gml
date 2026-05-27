function scr_tail_endgame_solve(start_board, max_depth, max_nodes, time_limit_ms) {
    show_debug_message("Trying Tail Endgame DFS...");

    var total_start = scr_count_gems(start_board);

    if (total_start > 6) {
        show_debug_message("Tail Endgame skipped: too many gems = " + string(total_start));
        return undefined;
    }

    if (is_undefined(max_depth) || max_depth <= 0) {
        max_depth = 24;
    }

    if (is_undefined(max_nodes) || max_nodes <= 0) {
        max_nodes = 80000;
    }

    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) {
        time_limit_ms = 8000;
    }

    var start_time = get_timer();

    for (var depth_i = 1; depth_i <= max_depth; depth_i++) {
        var elapsed_ms = (get_timer() - start_time) / 1000;

        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Tail Endgame timeout before depth " + string(depth_i));
            return undefined;
        }

        var visited = ds_map_create();
        ds_map_set(visited, scr_board_key(start_board), true);

        var stats = {
            nodes: 0,
            max_nodes: max_nodes
        };

        show_debug_message("Tail DFS depth: " + string(depth_i));

        var result = scr_tail_dfs_core(
            scr_clone_board(start_board),
            [],
            depth_i,
            visited,
            stats,
            start_time,
            time_limit_ms,
            0
        );

        ds_map_destroy(visited);

        if (!is_undefined(result)) {
            show_debug_message("Tail Endgame solved at depth " + string(depth_i));
            show_debug_message("Tail Endgame nodes: " + string(stats.nodes));
            return result;
        }
    }

    show_debug_message("Tail Endgame failed.");
    return undefined;
}