function scr_beam_lite_solve(start_board, max_steps, beam_width, max_children, time_limit_ms) {
    show_debug_message("Trying Beam Lite Solver v3 no-empty...");

    if (is_undefined(max_steps) || max_steps <= 0) {
        max_steps = 90;
    }

    if (is_undefined(beam_width) || beam_width <= 0) {
        beam_width = 60;
    }

    if (is_undefined(max_children) || max_children <= 0) {
        max_children = 12;
    }

    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) {
        time_limit_ms = 30000;
    }

    var start_time = get_timer();

    var global_seen = ds_map_create();
    var tail_tried = ds_map_create();

    ds_map_set(global_seen, scr_board_key(start_board), true);

    var beam = [];

    array_push(beam, {
        board: scr_clone_board(start_board),
        path: [],
        node_score: scr_beam_lite_state_score(start_board)
    });

    var best_seen_total = scr_count_gems(start_board);

    for (var step_i = 0; step_i < max_steps; step_i++) {
        var elapsed_ms = (get_timer() - start_time) / 1000;

        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Beam Lite v3 timeout.");
            ds_map_destroy(global_seen);
            ds_map_destroy(tail_tried);
            return undefined;
        }

        var next_nodes = [];

        for (var b_i = 0; b_i < array_length(beam); b_i++) {
            var node = beam[b_i];

            if (scr_is_solved(node.board)) {
                show_debug_message("Beam Lite v3 solved at step " + string(step_i));
                ds_map_destroy(global_seen);
                ds_map_destroy(tail_tried);
                return node.path;
            }

            var node_total = scr_count_gems(node.board);
            var node_moves = scr_get_legal_moves(node.board);

            if (node_total > 0 && array_length(node_moves) <= 0) {
                continue;
            }

            if (node_total <= 10) {
                var node_key_for_tail = scr_board_key(node.board);

                if (!ds_map_exists(tail_tried, node_key_for_tail)) {
                    ds_map_set(tail_tried, node_key_for_tail, true);

                    show_debug_message("Beam Lite v3 found small board. Trying Small DFS tail...");
                    show_debug_message("Small board total = " + string(node_total));

                    var tail_from_node = scr_small_board_bfs_solve(node.board, 32, 45000, 12000);

                    if (!is_undefined(tail_from_node)) {
                        var test_board_tail = scr_clone_board(node.board);

                        for (var tt = 0; tt < array_length(tail_from_node); tt++) {
                            test_board_tail = scr_apply_move(test_board_tail, tail_from_node[tt]);
                        }

                        if (scr_is_solved(test_board_tail)) {
                            var full_tail_path = scr_path_join(node.path, tail_from_node);
                            show_debug_message("Beam Lite v3 + Small DFS solved.");
                            ds_map_destroy(global_seen);
                            ds_map_destroy(tail_tried);
                            return full_tail_path;
                        }
                    }
                }
            }

            var candidates = [];

            var before_total = scr_count_gems(node.board);
            var before_clearable = scr_count_clearable_gems(node.board);
            var before_specials = scr_count_specials(node.board);

            for (var m_i = 0; m_i < array_length(node_moves); m_i++) {
                var mv = node_moves[m_i];

                if (array_length(node.path) > 0) {
                    var last_mv = node.path[array_length(node.path) - 1];

                    if (scr_is_reverse_move(last_mv, mv)) {
                        continue;
                    }
                }

                var next_board = scr_apply_move(node.board, mv);
                var key = scr_board_key(next_board);

                if (ds_map_exists(global_seen, key)) {
                    continue;
                }

                var after_total = scr_count_gems(next_board);
                var after_clearable = scr_count_clearable_gems(next_board);
                var after_specials = scr_count_specials(next_board);

                if (after_total == 0) {
                    var solved_path = scr_path_append(node.path, mv);
                    show_debug_message("Beam Lite v3 solved directly.");
                    ds_map_destroy(global_seen);
                    ds_map_destroy(tail_tried);
                    return solved_path;
                }

                var next_legal = scr_get_legal_moves(next_board);
                var next_legal_count = array_length(next_legal);

                if (after_total > 0 && next_legal_count <= 0) {
                    continue;
                }

                var move_score_value = 0;

                move_score_value += (before_total - after_total) * 4000000;
                move_score_value += (before_clearable - after_clearable) * 1500000;
                move_score_value += scr_beam_lite_state_score(next_board);

                if (after_total < best_seen_total) {
                    move_score_value += 2000000;
                }

                if (after_total <= 12) {
                    move_score_value += next_legal_count * 500000;
                }

                if (after_total <= 8) {
                    move_score_value += next_legal_count * 800000;
                }

                if (after_specials < before_specials) {
                    move_score_value += 1000000;
                }

                var a = node.board[mv.r1][mv.c1];
                var b = node.board[mv.r2][mv.c2];

                if (a.pwr == 1 || b.pwr == 1) {
                    move_score_value += 300000;
                }

                if (a.gem == GEM_HYPER || b.gem == GEM_HYPER) {
                    move_score_value += 400000;
                }

                array_push(candidates, {
                    move: mv,
                    board: next_board,
                    key: key,
                    node_score: move_score_value
                });
            }

            candidates = scr_beam_lite_take_best(candidates, max_children);

            for (var c_i = 0; c_i < array_length(candidates); c_i++) {
                var cand = candidates[c_i];

                ds_map_set(global_seen, cand.key, true);

                array_push(next_nodes, {
                    board: cand.board,
                    path: scr_path_append(node.path, cand.move),
                    node_score: cand.node_score
                });
            }
        }

        if (array_length(next_nodes) == 0) {
            show_debug_message("Beam Lite v3 stopped: no next nodes.");
            ds_map_destroy(global_seen);
            ds_map_destroy(tail_tried);
            return undefined;
        }

        beam = scr_beam_lite_take_best(next_nodes, beam_width);

        var current_best_total = scr_count_gems(beam[0].board);

        if (current_best_total < best_seen_total) {
            best_seen_total = current_best_total;
        }

        if (step_i mod 5 == 0) {
            show_debug_message(
                "Beam Lite v3 step " + string(step_i)
                + " | beam = " + string(array_length(beam))
                + " | best_total = " + string(current_best_total)
                + " | best_seen_total = " + string(best_seen_total)
                + " | best_legal = " + string(array_length(scr_get_legal_moves(beam[0].board)))
            );
        }
    }

    show_debug_message("Beam Lite v3 failed.");
    ds_map_destroy(global_seen);
    ds_map_destroy(tail_tried);
    return undefined;
}