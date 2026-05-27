function scr_iddfs_smart(start_board, max_depth, time_limit_ms, max_branch, max_nodes) {
    var start_time = get_timer();

    for (var lim = 1; lim <= max_depth; lim++) {
        var elapsed_ms = (get_timer() - start_time) / 1000;

        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Smart IDDFS timeout.");
            return undefined;
        }

        show_debug_message("Smart IDDFS depth limit: " + string(lim));

        var seen = ds_map_create();
        ds_map_set(seen, scr_board_key(start_board), true);

        var ctrl = {
            nodes: 0,
            max_nodes: max_nodes
        };

        var result = scr_dls_smart(
            start_board,
            [],
            seen,
            0,
            lim,
            start_time,
            time_limit_ms,
            undefined,
            max_branch,
            ctrl
        );

        show_debug_message("Nodes searched at limit " + string(lim) + ": " + string(ctrl.nodes));

        ds_map_destroy(seen);

        if (!is_undefined(result)) {
            return result;
        }
    }

    return undefined;
}