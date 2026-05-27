function scr_beam_solve(start_board, max_depth, beam_width, move_limit, time_limit_ms, candidate_cap) {
    show_debug_message("scr_beam_solve started");
    show_debug_message("Beam max_depth: " + string(max_depth));
    show_debug_message("Beam width: " + string(beam_width));
    show_debug_message("Move limit: " + string(move_limit));
    show_debug_message("Time limit ms: " + string(time_limit_ms));
    show_debug_message("Candidate cap: " + string(candidate_cap));

    var start_time = get_timer();

    var start_node = {
        board: scr_clone_board(start_board),
        path: [],
        node_score: scr_state_score(start_board)
    };

    var frontier = [start_node];

    for (var d = 0; d < max_depth; d++) {
        var elapsed_ms = (get_timer() - start_time) / 1000;

        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Beam timeout at depth: " + string(d));
            return undefined;
        }

        show_debug_message("Beam depth: " + string(d) + " | frontier: " + string(array_length(frontier)));

        var candidates = [];

        var layer_seen = ds_map_create();

        for (var i = 0; i < array_length(frontier); i++) {
            elapsed_ms = (get_timer() - start_time) / 1000;

            if (elapsed_ms > time_limit_ms) {
                show_debug_message("Beam timeout inside frontier loop.");
                ds_map_destroy(layer_seen);
                return undefined;
            }

            var node = frontier[i];

            if (scr_is_solved(node.board)) {
                ds_map_destroy(layer_seen);
                return node.path;
            }

            var moves = scr_get_best_ordered_moves(node.board);
            var lim = min(move_limit, array_length(moves));

            for (var j = 0; j < lim; j++) {
                var mv = moves[j];

                var next_board = scr_apply_move(node.board, mv);

                var key = scr_board_key(next_board);

                if (ds_map_exists(layer_seen, key)) {
                    continue;
                }

                ds_map_set(layer_seen, key, true);

                var next_path = scr_path_append(node.path, mv);

                if (scr_is_solved(next_board)) {
                    ds_map_destroy(layer_seen);
                    return next_path;
                }

                var next_node = {
                    board: next_board,
                    path: next_path,
                    node_score: scr_state_score(next_board)
                };

                array_push(candidates, next_node);

              
                if (array_length(candidates) >= candidate_cap) {
                    candidates = scr_take_best_nodes(candidates, beam_width);
                }
            }
        }

        ds_map_destroy(layer_seen);

        show_debug_message("Candidates before trim: " + string(array_length(candidates)));

        if (array_length(candidates) == 0) {
            show_debug_message("No more candidates.");
            break;
        }

        frontier = scr_take_best_nodes(candidates, beam_width);
    }

    return undefined;
}