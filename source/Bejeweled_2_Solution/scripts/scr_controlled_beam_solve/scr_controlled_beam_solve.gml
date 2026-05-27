function scr_controlled_beam_solve(start_board, max_steps, beam_width, max_children, time_limit_ms) {
    show_debug_message("Trying Controlled Beam Solver v2 lookahead...");

    if (is_undefined(max_steps) || max_steps <= 0) {
        max_steps = 90;
    }

    if (is_undefined(beam_width) || beam_width <= 0) {
        beam_width = 80;
    }

    if (is_undefined(max_children) || max_children <= 0) {
        max_children = 18;
    }

    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) {
        time_limit_ms = 20000;
    }

    var start_time = get_timer();

    var beam = [];

    array_push(beam, {
        board: scr_clone_board(start_board),
        path: [],
        node_score: scr_controlled_beam_score(start_board)
    });

    for (var step_i = 0; step_i < max_steps; step_i++) {
        var elapsed_ms = (get_timer() - start_time) / 1000;

        if (elapsed_ms > time_limit_ms) {
            show_debug_message("Controlled Beam v2 timeout.");
            return undefined;
        }

        var next_nodes = [];
        var layer_seen = ds_map_create();

        for (var b_i = 0; b_i < array_length(beam); b_i++) {
            var node = beam[b_i];

            if (scr_is_solved(node.board)) {
                show_debug_message("Controlled Beam v2 solved at step " + string(step_i));
                ds_map_destroy(layer_seen);
                return node.path;
            }

            var moves = scr_get_legal_moves(node.board);

            if (array_length(moves) <= 0) {
                continue;
            }

            var candidates = [];

            var before_total = scr_count_gems(node.board);
            var before_clearable = scr_count_clearable_gems(node.board);
            var before_special = scr_count_specials(node.board);

            for (var m_i = 0; m_i < array_length(moves); m_i++) {
                var mv = moves[m_i];

                if (array_length(node.path) > 0) {
                    var last_mv = node.path[array_length(node.path) - 1];

                    if (scr_is_reverse_move(last_mv, mv)) {
                        continue;
                    }
                }

                var next_board = scr_apply_move(node.board, mv);

                if (scr_is_solved(next_board)) {
                    var solved_path = scr_path_append(node.path, mv);
                    show_debug_message("Controlled Beam v2 solved directly.");
                    ds_map_destroy(layer_seen);
                    return solved_path;
                }

                var key = scr_board_key(next_board);

                if (ds_map_exists(layer_seen, key)) {
                    continue;
                }

                var after_total = scr_count_gems(next_board);
                var after_clearable = scr_count_clearable_gems(next_board);
                var after_special = scr_count_specials(next_board);

                var next_moves = scr_get_legal_moves(next_board);
                var next_legal_count = array_length(next_moves);

                if (after_total > 0 && next_legal_count <= 0) {
                    continue;
                }

                var survivor_count = scr_controlled_survivor_count(next_board, 8);

                if (after_total > 0 && survivor_count <= 0) {
                    continue;
                }

                var score_value = 0;

                score_value += (before_total - after_total) * 4500000;
                score_value += (before_clearable - after_clearable) * 1200000;
                score_value += next_legal_count * 1200000;
                score_value += survivor_count * 2200000;
                score_value += scr_controlled_beam_score(next_board);

                if (after_total <= 12) {
                    score_value += next_legal_count * 2000000;
                    score_value += survivor_count * 3000000;
                }

                if (after_total <= 8) {
                    score_value += next_legal_count * 2500000;
                    score_value += survivor_count * 4000000;
                }

                if (after_total > 0 && next_legal_count <= 1) {
                    score_value -= 15000000;
                }

                if (after_total > 0 && after_special < before_special) {
                    score_value += 1000000;
                }

                var a = node.board[mv.r1][mv.c1];
                var b = node.board[mv.r2][mv.c2];

                if (a.pwr == 1 || b.pwr == 1) {
                    score_value += 500000;
                }

                if (a.gem == GEM_HYPER || b.gem == GEM_HYPER) {
                    score_value += 1000000;
                }

                array_push(candidates, {
                    move: mv,
                    board: next_board,
                    key: key,
                    node_score: score_value
                });
            }

            candidates = scr_controlled_take_best(candidates, max_children);

            for (var c_i = 0; c_i < array_length(candidates); c_i++) {
                var cand = candidates[c_i];

                ds_map_set(layer_seen, cand.key, true);

                array_push(next_nodes, {
                    board: cand.board,
                    path: scr_path_append(node.path, cand.move),
                    node_score: cand.node_score
                });
            }
        }

        if (array_length(next_nodes) <= 0) {
            ds_map_destroy(layer_seen);
            show_debug_message("Controlled Beam v2 stopped: no next nodes.");
            return undefined;
        }

        beam = scr_controlled_take_best(next_nodes, beam_width);

        ds_map_destroy(layer_seen);

        if (step_i mod 5 == 0) {
            show_debug_message(
                "Controlled Beam v2 step " + string(step_i)
                + " | beam = " + string(array_length(beam))
                + " | best_total = " + string(scr_count_gems(beam[0].board))
                + " | best_legal = " + string(array_length(scr_get_legal_moves(beam[0].board)))
                + " | survivor = " + string(scr_controlled_survivor_count(beam[0].board, 8))
            );
        }
    }

    show_debug_message("Controlled Beam v2 failed.");
    return undefined;
}