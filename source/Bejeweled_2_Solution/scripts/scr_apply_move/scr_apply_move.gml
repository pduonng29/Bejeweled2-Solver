function scr_apply_move(board, move) {
    var b = scr_clone_board(board);

    var did_hyper = scr_apply_hyper_swap(b, move.r1, move.c1, move.r2, move.c2);

    if (did_hyper) {
        scr_apply_gravity(b);

        while (true) {
            var changed_hyper = scr_resolve_matches_advanced(b, undefined);

            if (!changed_hyper) {
                break;
            }

            scr_apply_gravity(b);
        }
    } else {
        scr_swap_cells(b, move.r1, move.c1, move.r2, move.c2);

        var first = true;

        while (true) {
            var changed;

            if (first) {
                changed = scr_resolve_matches_advanced(b, move);
                first = false;
            } else {
                changed = scr_resolve_matches_advanced(b, undefined);
            }

            if (!changed) {
                break;
            }

            scr_apply_gravity(b);
        }
    }

    var bomb_exploded = scr_tick_bombs(b);

    if (bomb_exploded) {
        scr_apply_gravity(b);

        while (true) {
            var changed_after_bomb = scr_resolve_matches_advanced(b, undefined);

            if (!changed_after_bomb) {
                break;
            }

            scr_apply_gravity(b);
        }
    }

    return b;
}