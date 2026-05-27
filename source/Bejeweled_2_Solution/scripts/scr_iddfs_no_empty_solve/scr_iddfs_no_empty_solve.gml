function scr_iddfs_no_empty_solve(start_board, max_depth, max_nodes, time_limit_ms) {
    show_debug_message("Trying IDDFS No-Empty Solver...");

    if (is_undefined(max_depth) || max_depth <= 0) {
        max_depth = 32;
    }

    if (is_undefined(max_nodes) || max_nodes <= 0) {
        max_nodes = 250000;
    }

    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) {
        time_limit_ms = 30000;
    }

    var start_time = get_timer();

    for (var depth_i = 1; depth_i <= max_depth; depth_i++) {
        var elapsed_ms = (get_timer() - start_time) / 1000;

        if (elapsed_ms > time_limit_ms) {
            show_debug_message("IDDFS timeout before depth " + string(depth_i));
            return undefined;
        }

        var visited = ds_map_create();
        ds_map_set(visited, scr_board_key(start_board), true);

        var stats = {
            nodes: 0,
            max_nodes: max_nodes
        };

        show_debug_message("IDDFS depth: " + string(depth_i));

        var result = scr_iddfs_core(
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
            show_debug_message("IDDFS solved at depth " + string(depth_i));
            show_debug_message("IDDFS nodes: " + string(stats.nodes));
            return result;
        }

        if (stats.nodes >= max_nodes) {
            show_debug_message("IDDFS node limit reached at depth " + string(depth_i));
        }
    }

    show_debug_message("IDDFS failed.");
    return undefined;
}