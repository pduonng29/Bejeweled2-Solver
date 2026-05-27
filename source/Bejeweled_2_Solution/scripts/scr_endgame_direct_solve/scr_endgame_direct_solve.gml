function scr_endgame_direct_solve(start_board) {
    var b = scr_clone_board(start_board);
    var path = [];

    var gems = [];

    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            var cell = b[r][c];

            if (cell.gem >= 0 && cell.gem <= 6) {
                array_push(gems, {
                    r: r,
                    c: c,
                    gem: cell.gem
                });
            }
        }
    }

    if (array_length(gems) != 3) {
        return undefined;
    }

    if (gems[0].gem != gems[1].gem || gems[1].gem != gems[2].gem) {
        return undefined;
    }

    var pair_a = undefined;
    var pair_b = undefined;
    var third = undefined;
    var target_r = -1;
    var target_c = -1;

    for (var i = 0; i < 3; i++) {
        for (var j = i + 1; j < 3; j++) {
            var g1 = gems[i];
            var g2 = gems[j];

            if (g1.c == g2.c && abs(g1.r - g2.r) == 1) {
                pair_a = g1;
                pair_b = g2;

                for (var k = 0; k < 3; k++) {
                    if (k != i && k != j) {
                        third = gems[k];
                    }
                }

                target_c = g1.c;

                var min_r = min(g1.r, g2.r);
                var max_r = max(g1.r, g2.r);

                if (min_r - 1 >= 0 && b[min_r - 1][target_c].gem == GEM_EMPTY) {
                    target_r = min_r - 1;
                } else if (max_r + 1 < BOARD_H && b[max_r + 1][target_c].gem == GEM_EMPTY) {
                    target_r = max_r + 1;
                }

                break;
            }
        }

        if (!is_undefined(pair_a)) {
            break;
        }
    }

    if (is_undefined(pair_a) || is_undefined(third) || target_r < 0) {
        return undefined;
    }

    if (third.r != target_r) {
        return undefined;
    }

    var row = target_r;
    var cur_c = third.c;

    var h_step;

    if (target_c < cur_c) {
        h_step = -1;
    } else {
        h_step = 1;
    }

    var check_c = cur_c + h_step;

    while (check_c != target_c + h_step) {
        var path_cell = b[row][check_c];

        if (path_cell.gem == GEM_ROCK) {
            var moved_rock = false;

            if (row - 1 >= 0 && b[row - 1][check_c].gem == GEM_EMPTY) {
                var rock_mv_up = {
                    r1: row - 1,
                    c1: check_c,
                    r2: row,
                    c2: check_c
                };

                if (scr_is_valid_swap(b, rock_mv_up.r1, rock_mv_up.c1, rock_mv_up.r2, rock_mv_up.c2)) {
                    b = scr_apply_move(b, rock_mv_up);
                    array_push(path, rock_mv_up);
                    moved_rock = true;
                }
            }

            if (!moved_rock && row + 1 < BOARD_H && b[row + 1][check_c].gem == GEM_EMPTY) {
                var rock_mv_down = {
                    r1: row + 1,
                    c1: check_c,
                    r2: row,
                    c2: check_c
                };

                if (scr_is_valid_swap(b, rock_mv_down.r1, rock_mv_down.c1, rock_mv_down.r2, rock_mv_down.c2)) {
                    b = scr_apply_move(b, rock_mv_down);
                    array_push(path, rock_mv_down);
                    moved_rock = true;
                }
            }

            if (!moved_rock) {
                return undefined;
            }
        } else if (path_cell.gem != GEM_EMPTY && check_c != cur_c) {
            return undefined;
        }

        check_c += h_step;
    }

    while (cur_c != target_c) {
        var next_c = cur_c + h_step;

        var slide_mv = {
            r1: row,
            c1: cur_c,
            r2: row,
            c2: next_c
        };

        if (!scr_is_valid_swap(b, slide_mv.r1, slide_mv.c1, slide_mv.r2, slide_mv.c2)) {
            return undefined;
        }

        b = scr_apply_move(b, slide_mv);
        array_push(path, slide_mv);

        cur_c = next_c;

        if (scr_is_solved(b)) {
            return path;
        }
    }

    if (scr_is_solved(b)) {
        return path;
    }

    return undefined;
}