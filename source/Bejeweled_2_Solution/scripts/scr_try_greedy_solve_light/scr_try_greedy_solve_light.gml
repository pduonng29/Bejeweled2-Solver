function scr_try_greedy_solve_light(start_board, max_steps) {
    var board = scr_clone_board(start_board);
    var path = [];
    var prev_move = undefined;

    var seen = ds_map_create();
    ds_map_set(seen, scr_board_key(board), true);

    var no_progress_count = 0;
    var last_total = scr_count_gems(board);

    for (var step_i = 0; step_i < max_steps; step_i++) {
        if (scr_is_solved(board)) {
            show_debug_message("Greedy solved at step " + string(step_i));
            ds_map_destroy(seen);
            return path;
        }

        var moves = scr_get_legal_moves(board);

        if (array_length(moves) == 0) {
            show_debug_message("Greedy stopped: no legal moves.");
            show_debug_message("Final board:");
            scr_print_board(board);

            ds_map_destroy(seen);
            return undefined;
        }

        var best_move = undefined;
        var best_score_value = -99999999;
        var best_board = undefined;
        var best_key = "";

        for (var i = 0; i < array_length(moves); i++) {
            var mv = moves[i];

            if (scr_is_reverse_move(prev_move, mv)) {
                continue;
            }

            var nb = scr_apply_move(board, mv);
            var key = scr_board_key(nb);

            if (ds_map_exists(seen, key)) {
                continue;
            }

            var a = board[mv.r1][mv.c1];
            var b = board[mv.r2][mv.c2];

            var before_clearable = scr_count_clearable_gems(board);
            var after_clearable = scr_count_clearable_gems(nb);

            var before_rocks = scr_count_rocks(board);
            var after_rocks = scr_count_rocks(nb);

            var before_total = scr_count_gems(board);
            var after_total = scr_count_gems(nb);

            var removed_clearable = before_clearable - after_clearable;
            var removed_rocks = before_rocks - after_rocks;
            var removed_total = before_total - after_total;

            var mv_score = 0;

            mv_score += removed_total * 150000;
            mv_score += removed_clearable * 100000;
            mv_score += removed_rocks * 200000;

            if (a.pwr == 1 || b.pwr == 1) {
                mv_score += 100000;
            }

            if (a.gem == GEM_HYPER || b.gem == GEM_HYPER) {
                mv_score += 120000;
            }

            var is_slide = (a.gem == GEM_EMPTY && b.gem != GEM_EMPTY && b.gem != GEM_ROCK)
                         || (a.gem != GEM_EMPTY && a.gem != GEM_ROCK && b.gem == GEM_EMPTY);

            var is_rock_swap = (a.gem == GEM_ROCK && b.gem != GEM_EMPTY && b.gem != GEM_ROCK)
                            || (a.gem != GEM_EMPTY && a.gem != GEM_ROCK && b.gem == GEM_ROCK);

            if (is_slide || is_rock_swap) {
                mv_score += 1000;

                if (is_rock_swap) {
                    mv_score += 4000;
                }

                if (mv.r1 == mv.r2 && mv.c2 == mv.c1 - 1) {
                    mv_score += 3000;
                }

                if (mv.r1 == mv.r2 && mv.c2 == mv.c1 + 1 && removed_total > 0) {
                    mv_score += 3000;
                }

                mv_score += mv.c1 * 200;
            }

            if (removed_clearable == 0 && removed_rocks == 0 && removed_total == 0) {
                mv_score -= 500;
            }

            if (mv_score > best_score_value) {
                best_score_value = mv_score;
                best_move = mv;
                best_board = nb;
                best_key = key;
            }
        }

        if (is_undefined(best_move)) {
            show_debug_message("Greedy stopped: no unseen best move.");

            if (scr_count_gems(board) <= 12) {
                show_debug_message("Trying Small Board BFS before fail...");

                var small_tail_no_move = scr_small_board_bfs_solve(board, 18, 20000, 10000);

                if (!is_undefined(small_tail_no_move)) {
                    var test_board_small_no_move = scr_clone_board(board);

                    for (var sn = 0; sn < array_length(small_tail_no_move); sn++) {
                        test_board_small_no_move = scr_apply_move(test_board_small_no_move, small_tail_no_move[sn]);
                    }

                    if (scr_is_solved(test_board_small_no_move)) {
                        var full_small_no_move = scr_path_join(path, small_tail_no_move);
                        ds_map_destroy(seen);
                        return full_small_no_move;
                    }
                }
            }

            var direct_tail_no_move = scr_endgame_direct_solve(board);

            if (!is_undefined(direct_tail_no_move)) {
                var test_board_no_move = scr_clone_board(board);

                for (var tn = 0; tn < array_length(direct_tail_no_move); tn++) {
                    test_board_no_move = scr_apply_move(test_board_no_move, direct_tail_no_move[tn]);
                }

                if (scr_is_solved(test_board_no_move)) {
                    var full_direct_no_move = scr_path_join(path, direct_tail_no_move);
                    ds_map_destroy(seen);
                    return full_direct_no_move;
                }
            }

            show_debug_message("Final board:");
            scr_print_board(board);

            ds_map_destroy(seen);
            return undefined;
        }

        array_push(path, best_move);
        board = best_board;
        prev_move = best_move;
        ds_map_set(seen, best_key, true);

        var current_total = scr_count_gems(board);

        if (current_total >= last_total) {
            no_progress_count += 1;
        } else {
            no_progress_count = 0;
        }

        last_total = current_total;

        show_debug_message(
            "Greedy step " + string(step_i + 1)
            + " | move = (" + string(best_move.r1) + "," + string(best_move.c1)
            + ") -> (" + string(best_move.r2) + "," + string(best_move.c2) + ")"
            + " | move_score = " + string(best_score_value)
            + " | clearable = " + string(scr_count_clearable_gems(board))
            + " | rocks = " + string(scr_count_rocks(board))
            + " | total = " + string(scr_count_gems(board))
        );

        if (no_progress_count >= 25) {
            if (scr_count_gems(board) <= 12) {
                show_debug_message("Greedy stuck with small board. Trying Small Board BFS first...");

                var small_tail = scr_small_board_bfs_solve(board, 18, 20000, 10000);

                if (!is_undefined(small_tail)) {
                    var test_board_small = scr_clone_board(board);

                    for (var ts = 0; ts < array_length(small_tail); ts++) {
                        test_board_small = scr_apply_move(test_board_small, small_tail[ts]);
                    }

                    if (scr_is_solved(test_board_small)) {
                        var full_small_path = scr_path_join(path, small_tail);
                        ds_map_destroy(seen);
                        return full_small_path;
                    }
                }

                show_debug_message("Small Board BFS failed/rejected.");
            }

            show_debug_message("Greedy stuck. Trying Direct Endgame Solver first...");

            var direct_tail = scr_endgame_direct_solve(board);

            if (!is_undefined(direct_tail)) {
                var test_board_direct = scr_clone_board(board);

                for (var td = 0; td < array_length(direct_tail); td++) {
                    test_board_direct = scr_apply_move(test_board_direct, direct_tail[td]);
                }

                if (scr_is_solved(test_board_direct)) {
                    var full_direct_path = scr_path_join(path, direct_tail);
                    ds_map_destroy(seen);
                    return full_direct_path;
                }
            }

            show_debug_message("Direct Endgame failed/rejected. Trying Endgame BFS once...");

            var tail_path = scr_endgame_bfs(board, 50, 3000, 3000);

            if (!is_undefined(tail_path)) {
                var test_board_bfs = scr_clone_board(board);

                for (var tb = 0; tb < array_length(tail_path); tb++) {
                    test_board_bfs = scr_apply_move(test_board_bfs, tail_path[tb]);
                }

                if (scr_is_solved(test_board_bfs)) {
                    var full_path = scr_path_join(path, tail_path);
                    ds_map_destroy(seen);
                    return full_path;
                }
            }

            show_debug_message("Greedy stopped: no progress for 25 steps.");
            show_debug_message("Final board:");
            scr_print_board(board);

            ds_map_destroy(seen);
            return undefined;
        }
    }

    if (scr_is_solved(board)) {
        ds_map_destroy(seen);
        return path;
    }

    if (scr_count_gems(board) <= 12) {
        show_debug_message("Greedy reached max steps with small board. Trying Small Board BFS first...");

        var small_tail2 = scr_small_board_bfs_solve(board, 18, 20000, 10000);

        if (!is_undefined(small_tail2)) {
            var test_board_small2 = scr_clone_board(board);

            for (var ts2 = 0; ts2 < array_length(small_tail2); ts2++) {
                test_board_small2 = scr_apply_move(test_board_small2, small_tail2[ts2]);
            }

            if (scr_is_solved(test_board_small2)) {
                var full_small_path2 = scr_path_join(path, small_tail2);
                ds_map_destroy(seen);
                return full_small_path2;
            }
        }

        show_debug_message("Small Board BFS failed/rejected.");
    }

    show_debug_message("Greedy reached max steps. Trying Direct Endgame Solver first...");

    var direct_tail2 = scr_endgame_direct_solve(board);

    if (!is_undefined(direct_tail2)) {
        var test_board_direct2 = scr_clone_board(board);

        for (var td2 = 0; td2 < array_length(direct_tail2); td2++) {
            test_board_direct2 = scr_apply_move(test_board_direct2, direct_tail2[td2]);
        }

        if (scr_is_solved(test_board_direct2)) {
            var full_direct_path2 = scr_path_join(path, direct_tail2);
            ds_map_destroy(seen);
            return full_direct_path2;
        }
    }

    show_debug_message("Direct Endgame failed/rejected. Trying Endgame BFS once...");

    var tail_path2 = scr_endgame_bfs(board, 50, 3000, 3000);

    if (!is_undefined(tail_path2)) {
        var test_board_bfs2 = scr_clone_board(board);

        for (var tb2 = 0; tb2 < array_length(tail_path2); tb2++) {
            test_board_bfs2 = scr_apply_move(test_board_bfs2, tail_path2[tb2]);
        }

        if (scr_is_solved(test_board_bfs2)) {
            var full_path2 = scr_path_join(path, tail_path2);
            ds_map_destroy(seen);
            return full_path2;
        }
    }

    show_debug_message("Greedy reached max steps. Final board:");
    scr_print_board(board);

    ds_map_destroy(seen);
    return undefined;
}