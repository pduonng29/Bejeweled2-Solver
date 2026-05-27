function scr_verify_solution(start_board, path) {
    show_debug_message("VERIFY SOLUTION:");

    var board = scr_clone_board(start_board);

    for (var i = 0; i < array_length(path); i++) {
        var mv = path[i];

        if (!scr_inside_board(mv.r1, mv.c1) || !scr_inside_board(mv.r2, mv.c2)) {
            show_debug_message("VERIFY FAILED: move out of board at step " + string(i + 1));
            return false;
        }

        var dist = abs(mv.r1 - mv.r2) + abs(mv.c1 - mv.c2);

        if (dist != 1) {
            show_debug_message("VERIFY FAILED: move is not adjacent at step " + string(i + 1));
            return false;
        }

        if (!scr_is_real_legal_move(board, mv)) {
            show_debug_message("VERIFY FAILED: move is not legal at step " + string(i + 1));
            show_debug_message(
                "Bad move: (" + string(mv.r1) + "," + string(mv.c1)
                + ") -> (" + string(mv.r2) + "," + string(mv.c2) + ")"
            );
            scr_print_board(board);
            return false;
        }

        board = scr_apply_move(board, mv);

        show_debug_message(
            "Verify step " + string(i + 1)
            + " OK | total = " + string(scr_count_gems(board))
            + " | clearable = " + string(scr_count_clearable_gems(board))
            + " | rocks = " + string(scr_count_rocks(board))
        );
    }

    if (scr_is_solved(board)) {
        show_debug_message("VERIFY OK: board fully empty.");
        return true;
    }

    show_debug_message("VERIFY FAILED: board not empty.");
    scr_print_board(board);
    return false;
}
