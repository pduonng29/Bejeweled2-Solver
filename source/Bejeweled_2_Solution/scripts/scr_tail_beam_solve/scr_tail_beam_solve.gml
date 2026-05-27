function scr_tail_beam_solve(start_board, max_steps, beam_width, max_children, time_limit_ms) {
    show_debug_message("Trying Tail Priority Solver v15...");

    var start_total = scr_count_gems(start_board);

    if (start_total <= 0) {
        return [];
    }

    if (start_total > 14) {
        show_debug_message("Tail Priority skipped: too many gems = " + string(start_total));
        return undefined;
    }

    if (is_undefined(max_steps) || max_steps <= 0) {
        max_steps = 44;
    }

    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) {
        time_limit_ms = 22000;
    }

    var max_nodes = 18000;
    var start_time = get_timer();

    var frontier = [];
    var visited = ds_map_create();

    var start_key = scr_board_key(start_board);
    ds_map_set(visited, start_key, 0);

    var start_legal = array_length(scr_get_legal_moves(start_board));

    array_push(frontier, {
        board: scr_clone_board(start_board),
        path: [],
        node_score: ((64 - start_total) * 10000000) + (start_legal * 700000),
        no_clear_count: 0
    });

    var nodes = 0;
    var best_total = start_total;
    var best_legal = start_legal;
    var best_path_len = 0;

    while (array_length(frontier) > 0) {
        var elapsed_ms = (get_timer() - start_time) / 1000;

        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Tail Priority timeout.");
            show_debug_message("Tail Priority nodes = " + string(nodes));
            ds_map_destroy(visited);
            return undefined;
        }

        if (nodes >= max_nodes) {
            show_debug_message("Tail Priority node limit reached.");
            show_debug_message("Tail Priority nodes = " + string(nodes));
            ds_map_destroy(visited);
            return undefined;
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
            show_debug_message("Tail Priority solved.");
            show_debug_message("Tail Priority nodes = " + string(nodes));
            show_debug_message("Tail Priority depth = " + string(array_length(node.path)));
            ds_map_destroy(visited);
            return node.path;
        }

        var depth_now = array_length(node.path);

        if (depth_now >= max_steps) {
            continue;
        }

        var moves = scr_get_legal_moves(node.board);

        if (array_length(moves) <= 0) {
            continue;
        }

        var before_total = scr_count_gems(node.board);
        var before_clearable = scr_count_clearable_gems(node.board);
        var before_specials = scr_count_specials(node.board);
        var before_legal = array_length(moves);

        var candidates = [];

        for (var mi = 0; mi < array_length(moves); mi++) {
            var mv = moves[mi];

            if (depth_now > 0) {
                var last_mv = node.path[depth_now - 1];

                if (scr_is_reverse_move(last_mv, mv)) {
                    continue;
                }
            }

            if (!scr_is_real_legal_move(node.board, mv)) {
                continue;
            }

            var nb = scr_apply_move(node.board, mv);
            var new_path = scr_path_append(node.path, mv);

            if (scr_is_solved(nb)) {
                show_debug_message("Tail Priority solved directly.");
                show_debug_message("Tail Priority nodes = " + string(nodes));
                show_debug_message("Tail Priority depth = " + string(array_length(new_path)));
                ds_map_destroy(visited);
                return new_path;
            }

            var after_total = scr_count_gems(nb);
            var after_legal = array_length(scr_get_legal_moves(nb));

            if (after_total > 0 && after_legal <= 0) {
                continue;
            }

            var key = scr_board_key(nb);
            var new_depth = array_length(new_path);

            if (ds_map_exists(visited, key)) {
                var old_depth = visited[? key];

                if (old_depth <= new_depth) {
                    continue;
                }
            }

            var after_clearable = scr_count_clearable_gems(nb);
            var after_specials = scr_count_specials(nb);
            var removed_total = before_total - after_total;
            var removed_clearable = before_clearable - after_clearable;

            var next_no_clear = node.no_clear_count;

            if (removed_total <= 0 && removed_clearable <= 0) {
                next_no_clear += 1;
            } else {
                next_no_clear = 0;
            }

            if (next_no_clear > 22) {
                continue;
            }

            var score_value = 0;
            score_value += (64 - after_total) * 9000000;
            score_value += removed_total * 8000000;
            score_value += removed_clearable * 2500000;
            score_value += after_legal * 1200000;
            score_value += after_specials * 500000;
            score_value -= new_depth * 50000;
            score_value -= next_no_clear * 600000;

            if (after_total < before_total) {
                score_value += 3000000;
            }

            if (after_legal > before_legal) {
                score_value += 2500000;
            }

            if (after_total <= 12) {
                score_value += 6000000;
                score_value += after_legal * 1700000;
            }

            if (after_total <= 9) {
                score_value += 9000000;
                score_value += after_legal * 2200000;
            }

            if (after_total <= 6) {
                score_value += 12000000;
                score_value += after_legal * 3000000;
            }

            array_push(candidates, {
                board: nb,
                path: new_path,
                key: key,
                node_score: score_value,
                no_clear_count: next_no_clear
            });
        }

        candidates = scr_mixed_take_best(candidates, 36);

        for (var ci = 0; ci < array_length(candidates); ci++) {
            var cand = candidates[ci];
            ds_map_set(visited, cand.key, array_length(cand.path));
            array_push(frontier, cand);

            var cand_total = scr_count_gems(cand.board);
            var cand_legal = array_length(scr_get_legal_moves(cand.board));

            if (cand_total < best_total || (cand_total == best_total && cand_legal > best_legal)) {
                best_total = cand_total;
                best_legal = cand_legal;
                best_path_len = array_length(cand.path);
            }
        }

        if (array_length(frontier) > 650) {
            frontier = scr_mixed_take_best(frontier, 650);
        }

        if (nodes mod 500 == 0) {
            show_debug_message(
                "Tail Priority nodes = " + string(nodes)
                + " | frontier = " + string(array_length(frontier))
                + " | best_total = " + string(best_total)
                + " | best_legal = " + string(best_legal)
                + " | best_depth = " + string(best_path_len)
            );
        }
    }

    show_debug_message("Tail Priority failed.");
    show_debug_message("Tail Priority nodes = " + string(nodes));
    ds_map_destroy(visited);
    return undefined;
}
