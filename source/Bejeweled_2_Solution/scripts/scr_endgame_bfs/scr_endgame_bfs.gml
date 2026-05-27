function scr_endgame_bfs(start_board, max_steps, max_nodes, time_limit_ms) {
    show_debug_message("Trying Endgame BFS...");

    if (is_undefined(max_steps) || max_steps <= 0) {
        max_steps = 80;
    }

    if (is_undefined(max_nodes) || max_nodes <= 0) {
        max_nodes = 12000;
    }

    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) {
        time_limit_ms = 10000;
    }

    var start_time = get_timer();
    var visited = ds_map_create();

    var start_node = {
        board: scr_clone_board(start_board),
        path: []
    };

    var queue = [start_node];
    var head_i = 0;
    var node_count = 0;

    ds_map_set(visited, scr_board_key(start_board), true);

    while (head_i < array_length(queue)) {
        var elapsed_ms = (get_timer() - start_time) / 1000;

        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Endgame BFS timeout. Nodes: " + string(node_count));
            ds_map_destroy(visited);
            return undefined;
        }

        if (node_count >= max_nodes) {
            show_debug_message("Endgame BFS stopped: node limit. Nodes: " + string(node_count));
            ds_map_destroy(visited);
            return undefined;
        }

        var node = queue[head_i];
        head_i += 1;
        node_count += 1;

        if (scr_is_solved(node.board)) {
            show_debug_message("Endgame BFS solved. Nodes: " + string(node_count));
            ds_map_destroy(visited);
            return node.path;
        }

        var moves = scr_get_legal_moves(node.board);

        if (array_length(node.path) >= max_steps) {
            continue;
        }

        var candidates = [];

        for (var i = 0; i < array_length(moves); i++) {
            var mv = moves[i];

            if (array_length(node.path) > 0) {
                var last_mv = node.path[array_length(node.path) - 1];

                if (scr_is_reverse_move(last_mv, mv)) {
                    continue;
                }
            }

            var next_board = scr_apply_move(node.board, mv);
            var key = scr_board_key(next_board);

            if (ds_map_exists(visited, key)) {
                continue;
            }

            var next_path = scr_path_append(node.path, mv);

            if (scr_is_solved(next_board)) {
                show_debug_message("Endgame BFS solved. Nodes: " + string(node_count));
                ds_map_destroy(visited);
                return next_path;
            }

            var candidate_score = scr_endgame_state_score(next_board);

            array_push(candidates, {
                board: next_board,
                path: next_path,
                key: key,
                node_score: candidate_score
            });
        }

        candidates = scr_take_best_nodes(candidates, 12);

        for (var j = 0; j < array_length(candidates); j++) {
            var cand = candidates[j];

            ds_map_set(visited, cand.key, true);

            array_push(queue, {
                board: cand.board,
                path: cand.path
            });
        }

        if (node_count mod 200 == 0) {
            show_debug_message("Endgame BFS nodes: " + string(node_count));
        }
    }

    show_debug_message("Endgame BFS failed. Nodes: " + string(node_count));

    ds_map_destroy(visited);
    return undefined;
}