function scr_mixed_beam_solve(start_board, max_steps, beam_width, max_children, time_limit_ms) {
    show_debug_message("Trying Mixed Beam Solver PORTFOLIO v15 oriented...");

    if (is_undefined(max_steps) || max_steps <= 0) {
        max_steps = 170;
    }

    if (is_undefined(beam_width) || beam_width <= 0) {
        beam_width = 110;
    }

    if (is_undefined(max_children) || max_children <= 0) {
        max_children = 28;
    }

    if (is_undefined(time_limit_ms) || time_limit_ms <= 0) {
        time_limit_ms = 150000;
    }

    var global_start_time = get_timer();
    var profile_count = 2;

    for (var profile_idx = 0; profile_idx < profile_count; profile_idx++) {
        show_debug_message("Mixed Portfolio profile = " + string(profile_idx));

        var profile_start_time = get_timer();
        var profile_time_limit = time_limit_ms / profile_count;

        if (profile_idx == profile_count - 1) {
            profile_time_limit = time_limit_ms;
        }

        var p_beam_width = beam_width;
        var p_max_children = max_children;

        if (profile_idx == 1) {
            p_beam_width = beam_width + 40;
            p_max_children = max_children + 8;
        }

        if (profile_idx == 2) {
            p_beam_width = beam_width + 20;
            p_max_children = max_children + 12;
        }

        if (profile_idx == 3) {
            p_beam_width = beam_width + 60;
            p_max_children = max_children;
        }

        if (profile_idx == 4) {
            p_beam_width = beam_width + 80;
            p_max_children = max_children + 16;
        }

        var beam = [];

        array_push(beam, {
            board: scr_clone_board(start_board),
            path: [],
            node_score: scr_mixed_board_score(start_board),
            no_clear_count: 0
        });

        var best_debug_board = scr_clone_board(start_board);
        var best_debug_path = [];
        var best_debug_total = scr_count_gems(start_board);
        var best_debug_legal = array_length(scr_get_legal_moves(start_board));
        var best_debug_score = -999999999999;

        var tail_tried = ds_map_create();
        var tail_attempts = 0;
        var max_tail_attempts = 10;

        for (var step_i = 0; step_i < max_steps; step_i++) {
            var elapsed_all_ms = (get_timer() - global_start_time) / 1000;
            var elapsed_profile_ms = (get_timer() - profile_start_time) / 1000;

            if (elapsed_all_ms > time_limit_ms || elapsed_profile_ms > profile_time_limit) {
                show_debug_message("Mixed Portfolio profile timeout = " + string(profile_idx));
                break;
            }

            var next_nodes = [];
            var layer_seen = ds_map_create();

            for (var b_i = 0; b_i < array_length(beam); b_i++) {
                var node = beam[b_i];

                if (scr_is_solved(node.board)) {
                    show_debug_message("Mixed Portfolio solved at profile " + string(profile_idx) + " step " + string(step_i));
                    ds_map_destroy(layer_seen);
                    ds_map_destroy(tail_tried);
                    return node.path;
                }

                var moves = scr_get_legal_moves(node.board);

                if (array_length(moves) <= 0) {
                    continue;
                }

                var before_total = scr_count_gems(node.board);
                var before_clearable = scr_count_clearable_gems(node.board);
                var before_rocks = scr_count_rocks(node.board);
                var before_specials = scr_count_specials(node.board);
                var before_legal = array_length(moves);

                var candidates = [];

                for (var m_i = 0; m_i < array_length(moves); m_i++) {
                    var mv = moves[m_i];

                    if (array_length(node.path) > 0) {
                        var last_mv = node.path[array_length(node.path) - 1];

                        if (scr_is_reverse_move(last_mv, mv)) {
                            continue;
                        }
                    }

                    if (!scr_is_real_legal_move(node.board, mv)) {
                        continue;
                    }

                    var cell_a = node.board[mv.r1][mv.c1];
                    var cell_b = node.board[mv.r2][mv.c2];

                    var next_board = scr_apply_move(node.board, mv);
                    var new_path = scr_path_append(node.path, mv);

                    if (scr_is_solved(next_board)) {
                        show_debug_message("Mixed Portfolio solved directly at profile " + string(profile_idx));
                        ds_map_destroy(layer_seen);
                        ds_map_destroy(tail_tried);
                        return new_path;
                    }

                    var after_total = scr_count_gems(next_board);
                    var after_legal = array_length(scr_get_legal_moves(next_board));

                    if (after_total > 0 && after_legal <= 0) {
                        continue;
                    }

                    var key = scr_board_key(next_board);

                    if (ds_map_exists(layer_seen, key)) {
                        continue;
                    }

                    var after_clearable = scr_count_clearable_gems(next_board);
                    var after_rocks = scr_count_rocks(next_board);
                    var after_specials = scr_count_specials(next_board);

                    var removed_total = before_total - after_total;
                    var removed_clearable = before_clearable - after_clearable;
                    var removed_rocks = before_rocks - after_rocks;
                    var created_specials = after_specials - before_specials;

                    var next_no_clear_count = node.no_clear_count;

                    if (removed_total <= 0 && removed_clearable <= 0 && removed_rocks <= 0) {
                        next_no_clear_count += 1;
                    } else {
                        next_no_clear_count = 0;
                    }

                    if (next_no_clear_count > 18) {
                        continue;
                    }

                    var score_value = 0;
                    score_value += (64 - after_total) * 1000000;
                    score_value += (64 - after_clearable) * 450000;
                    score_value += after_legal * 180000;
                    score_value += after_specials * 180000;
                    score_value -= array_length(new_path) * 15000;
                    score_value -= next_no_clear_count * 650000;

                    if (profile_idx == 0) {
                        score_value += removed_total * 2500000;
                        score_value += removed_clearable * 1600000;
                        score_value += removed_rocks * 7000000;
                        score_value += after_legal * 450000;
                    }

                    if (profile_idx == 1) {
                        score_value += removed_total * 900000;
                        score_value += removed_clearable * 800000;
                        score_value += after_legal * 1600000;
                        score_value += created_specials * 1800000;
                    }

                    if (profile_idx == 2) {
                        score_value += removed_total * 4200000;
                        score_value += removed_clearable * 2500000;
                        score_value += removed_rocks * 9000000;
                        score_value += after_legal * 250000;
                    }

                    if (profile_idx == 3) {
                        score_value += removed_total * 1600000;
                        score_value += after_specials * 1700000;
                        score_value += created_specials * 2500000;
                        score_value += after_legal * 700000;

                        if (cell_a.pwr == 1 || cell_b.pwr == 1) {
                            score_value += 2500000;
                        }

                        if (cell_a.gem == GEM_HYPER || cell_b.gem == GEM_HYPER) {
                            score_value += 4500000;
                        }
                    }

                    if (profile_idx == 4) {
                        score_value += removed_total * 1200000;
                        score_value += removed_clearable * 1000000;
                        score_value += after_legal * 1200000;

                        if (after_total < before_total) {
                            score_value += 1200000;
                        }

                        if (removed_total <= 0) {
                            score_value -= 300000;
                        }
                    }

                    if (after_total <= 24) {
                        score_value += after_legal * 600000;
                    }

                    if (after_total <= 18) {
                        score_value += after_legal * 900000;
                    }

                    if (after_total <= 14) {
                        score_value += 6000000;
                        score_value += after_legal * 1800000;

                        if (after_legal <= 1) {
                            score_value -= 12000000;
                        }

                        if (after_legal >= 4) {
                            score_value += 5000000;
                        }
                    }

                    if (after_total <= 10) {
                        score_value += 12000000;
                        score_value += after_legal * 2500000;

                        if (after_legal <= 1) {
                            score_value -= 15000000;
                        }
                    }

                    if (after_total <= 8) {
                        score_value += 9000000;
                        score_value += after_legal * 3200000;
                    }

                    if (after_total <= 6) {
                        score_value += 12000000;
                        score_value += after_legal * 4200000;
                    }

                    var tie = (mv.r1 * 97) + (mv.c1 * 31) + (mv.r2 * 17) + (mv.c2 * 7) + (profile_idx * 43);
                    score_value += tie;

                    array_push(candidates, {
                        move: mv,
                        board: next_board,
                        key: key,
                        node_score: score_value,
                        no_clear_count: next_no_clear_count
                    });
                }

                candidates = scr_mixed_take_best(candidates, p_max_children);

                for (var c_i = 0; c_i < array_length(candidates); c_i++) {
                    var cand = candidates[c_i];
                    ds_map_set(layer_seen, cand.key, true);
                    array_push(next_nodes, {
                        board: cand.board,
                        path: scr_path_append(node.path, cand.move),
                        node_score: cand.node_score,
                        no_clear_count: cand.no_clear_count
                    });
                }
            }

            if (array_length(next_nodes) <= 0) {
                ds_map_destroy(layer_seen);
                show_debug_message("Mixed Portfolio profile stopped: no next nodes = " + string(profile_idx));
                break;
            }

            if (array_length(next_nodes) > 360) {
                next_nodes = scr_mixed_take_best(next_nodes, 360);
            }

            beam = scr_mixed_take_best(next_nodes, p_beam_width);
            ds_map_destroy(layer_seen);

            var current_total = scr_count_gems(beam[0].board);
            var current_legal = array_length(scr_get_legal_moves(beam[0].board));
            var current_score = beam[0].node_score;

            if (current_total < best_debug_total || (current_total == best_debug_total && current_legal > best_debug_legal) || (current_total == best_debug_total && current_legal == best_debug_legal && current_score > best_debug_score)) {
                best_debug_total = current_total;
                best_debug_legal = current_legal;
                best_debug_score = current_score;
                best_debug_board = scr_clone_board(beam[0].board);
                best_debug_path = beam[0].path;
            }

            var tail_checks_this_step = 0;

            for (var tb = 0; tb < array_length(beam); tb++) {
                if (tail_attempts >= max_tail_attempts) {
                    break;
                }

                if (tail_checks_this_step >= 3) {
                    break;
                }

                var tail_board = beam[tb].board;
                var tail_total = scr_count_gems(tail_board);

                if (tail_total > 14) {
                    continue;
                }

                var tail_legal = array_length(scr_get_legal_moves(tail_board));

                if (tail_total > 0 && tail_legal <= 0) {
                    continue;
                }

                var tail_key = scr_board_key(tail_board);

                if (ds_map_exists(tail_tried, tail_key)) {
                    continue;
                }

                ds_map_set(tail_tried, tail_key, true);
                tail_attempts += 1;
                tail_checks_this_step += 1;

                var tail_result = scr_tail_beam_solve(tail_board, 36, 0, 0, 9000);

                if (!is_undefined(tail_result)) {
                    var test_tail = scr_clone_board(tail_board);
                    var tail_ok = true;

                    for (var tr = 0; tr < array_length(tail_result); tr++) {
                        if (!scr_is_real_legal_move(test_tail, tail_result[tr])) {
                            tail_ok = false;
                            break;
                        }

                        test_tail = scr_apply_move(test_tail, tail_result[tr]);
                    }

                    if (tail_ok && scr_is_solved(test_tail)) {
                        show_debug_message("Mixed Portfolio solved by tail.");
                        ds_map_destroy(tail_tried);
                        return scr_path_join(beam[tb].path, tail_result);
                    }
                }
            }

            if (step_i mod 10 == 0) {
                show_debug_message(
                    "Mixed Portfolio profile " + string(profile_idx)
                    + " step " + string(step_i)
                    + " | beam = " + string(array_length(beam))
                    + " | best_total = " + string(current_total)
                    + " | best_legal = " + string(current_legal)
                    + " | no_clear = " + string(beam[0].no_clear_count)
                    + " | tail_attempts = " + string(tail_attempts)
                );
            }
        }
        show_debug_message("Mixed Portfolio profile failed = " + string(profile_idx)
            + " | best_total = " + string(best_debug_total)
            + " | best_legal = " + string(best_debug_legal)
            + " | best_path_len = " + string(array_length(best_debug_path)));

        ds_map_destroy(tail_tried);
    }

    show_debug_message("Mixed Beam Solver PORTFOLIO v3 failed.");
    return undefined;
}
