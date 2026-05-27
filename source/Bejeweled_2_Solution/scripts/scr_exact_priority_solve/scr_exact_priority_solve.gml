function scr_exact_priority_solve(start_board, max_depth, node_limit, time_limit_ms) {
    show_debug_message("Trying Exact Priority Solver RAM-SAFE v18...");

    if (is_undefined(max_depth) || max_depth <= 0) max_depth = 70;
    if (is_undefined(node_limit) || node_limit <= 0) node_limit = 12000;
    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) time_limit_ms = 12000;

    var max_frontier = 70;
    var max_children_per_node = 8;
    var max_tail_attempts = 2;
    var start_time = get_timer();

    var frontier = [];
    var visited = ds_map_create();
    var tail_tried = ds_map_create();

    var start_key = scr_board_key(start_board);
    ds_map_set(visited, start_key, 0);

    var start_total = scr_count_gems(start_board);
    var start_legal = array_length(scr_get_legal_moves(start_board));

    array_push(frontier, {
        board: scr_clone_board(start_board),
        path: [],
        node_score: ((64 - start_total) * 10000000) + (start_legal * 100000)
    });

    var nodes = 0;
    var best_board = scr_clone_board(start_board);
    var best_path = [];
    var best_total = start_total;
    var best_legal = start_legal;
    var tail_attempts = 0;

    while (array_length(frontier) > 0) {
        var elapsed_ms = (get_timer() - start_time) / 1000;
        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Exact Priority v18 timeout.");
            break;
        }
        if (nodes >= node_limit) {
            show_debug_message("Exact Priority v18 node limit reached.");
            break;
        }

        var best_i = 0;
        var best_score = frontier[0].node_score;
        for (var fi = 1; fi < array_length(frontier); fi++) {
            if (frontier[fi].node_score > best_score) {
                best_score = frontier[fi].node_score;
                best_i = fi;
            }
        }

        var node = frontier[best_i];
        array_delete(frontier, best_i, 1);
        nodes += 1;

        if (scr_is_solved(node.board)) {
            show_debug_message("Exact Priority v18 solved.");
            show_debug_message("Exact nodes = " + string(nodes));
            ds_map_destroy(tail_tried);
            ds_map_destroy(visited);
            return node.path;
        }

        var current_total = scr_count_gems(node.board);
        var current_legal = array_length(scr_get_legal_moves(node.board));

        if (current_total < best_total || (current_total == best_total && current_legal > best_legal)) {
            best_total = current_total;
            best_legal = current_legal;
            best_board = scr_clone_board(node.board);
            best_path = node.path;
            show_debug_message("Exact v18 best | total=" + string(best_total)
                + " | legal=" + string(best_legal)
                + " | depth=" + string(array_length(best_path))
                + " | nodes=" + string(nodes)
                + " | frontier=" + string(array_length(frontier)));
        }

        if (array_length(node.path) >= max_depth) continue;

        var moves = scr_get_legal_moves(node.board);
        if (array_length(moves) <= 0) continue;

        var before_total = scr_count_gems(node.board);
        var before_clearable = scr_count_clearable_gems(node.board);
        var before_specials = scr_count_specials(node.board);
        var children = [];

        for (var mi = 0; mi < array_length(moves); mi++) {
            var mv = moves[mi];

            if (array_length(node.path) > 0) {
                var last_mv = node.path[array_length(node.path) - 1];
                if (scr_is_reverse_move(last_mv, mv)) continue;
            }
            if (!scr_is_real_legal_move(node.board, mv)) continue;

            var nb = scr_apply_move(node.board, mv);
            var after_total = scr_count_gems(nb);
            var after_legal = array_length(scr_get_legal_moves(nb));

            if (after_total > 0 && after_legal <= 0) continue;

            var new_path = scr_path_append(node.path, mv);

            if (scr_is_solved(nb)) {
                show_debug_message("Exact Priority v18 solved directly.");
                show_debug_message("Exact nodes = " + string(nodes));
                ds_map_destroy(tail_tried);
                ds_map_destroy(visited);
                return new_path;
            }

            // v18: only a very small number of tail probes. v17 tried many deep
            // DFS probes and caused huge RAM spikes.
            if (after_total > 0 && after_total <= 10 && tail_attempts < max_tail_attempts) {
                var tail_key = scr_board_key(nb);
                if (!ds_map_exists(tail_tried, tail_key)) {
                    ds_map_set(tail_tried, tail_key, true);
                    tail_attempts += 1;
                    show_debug_message("Exact v18 focused tail attempt " + string(tail_attempts)
                        + " | total=" + string(after_total)
                        + " | path_len=" + string(array_length(new_path)));

                    var tail_result = scr_small_board_bfs_solve(nb, 16, 7000, 2500);
                    if (!is_undefined(tail_result)) {
                        show_debug_message("Exact v18 focused tail solved.");
                        ds_map_destroy(tail_tried);
                        ds_map_destroy(visited);
                        return scr_path_join(new_path, tail_result);
                    }
                }
            }

            var key = scr_board_key(nb);
            var new_depth = array_length(new_path);
            if (ds_map_exists(visited, key)) {
                var old_depth = visited[? key];
                if (old_depth <= new_depth) continue;
            }

            var after_clearable = scr_count_clearable_gems(nb);
            var after_specials = scr_count_specials(nb);
            var removed_total = before_total - after_total;
            var removed_clearable = before_clearable - after_clearable;

            var score_value = 0;
            score_value += (64 - after_total) * 8000000;
            score_value += removed_total * 4200000;
            score_value += removed_clearable * 1800000;
            score_value += after_legal * 650000;
            score_value += after_specials * 300000;
            score_value -= new_depth * 25000;

            if (after_total <= 18) score_value += after_legal * 800000;
            if (after_total <= 12) {
                score_value += after_legal * 1400000;
                if (after_legal <= 1) score_value -= 9000000;
            }
            if (after_total <= 8) {
                score_value += 7000000;
                score_value += after_legal * 1800000;
            }
            if (after_specials < before_specials) score_value += 1200000;

            array_push(children, {
                board: nb,
                path: new_path,
                key: key,
                node_score: score_value
            });
        }

        children = scr_mixed_take_best(children, max_children_per_node);
        for (var ci = 0; ci < array_length(children); ci++) {
            var child = children[ci];
            ds_map_set(visited, child.key, array_length(child.path));
            array_push(frontier, {
                board: child.board,
                path: child.path,
                node_score: child.node_score
            });
        }

        if (array_length(frontier) > max_frontier) {
            frontier = scr_mixed_take_best(frontier, max_frontier);
        }
    }

    // One final shallow tail attempt only.
    if (best_total > 0 && best_total <= 10) {
        show_debug_message("Exact v18 final tail probe | total=" + string(best_total)
            + " | best_path_len=" + string(array_length(best_path)));
        var final_tail = scr_small_board_bfs_solve(best_board, 18, 9000, 3000);
        if (!is_undefined(final_tail)) {
            show_debug_message("Exact v18 final tail solved.");
            ds_map_destroy(tail_tried);
            ds_map_destroy(visited);
            return scr_path_join(best_path, final_tail);
        }
    }

    show_debug_message("Exact Priority v18 failed. nodes=" + string(nodes)
        + " | best_total=" + string(best_total)
        + " | best_legal=" + string(best_legal)
        + " | best_path_len=" + string(array_length(best_path)));

    ds_map_destroy(tail_tried);
    ds_map_destroy(visited);
    return undefined;
}
