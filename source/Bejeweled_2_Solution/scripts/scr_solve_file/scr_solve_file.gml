function scr_solve_file(path) {
    show_debug_message("Selected BPZ:");
    show_debug_message(path);

    show_debug_message("BPZ PATH USED BY TRUE SOLVER:");
    show_debug_message(path);

    var sol_path = scr_replace_extension(path, ".sol");

    show_debug_message("SOL PATH WILL BE:");
    show_debug_message(sol_path);


    var board = scr_read_bpz(path);

    show_debug_message("BPZ PARSER v16: board_start=" + string(global.__bpz_last_board_start)
        + " | read_end=" + string(global.__bpz_last_read_end)
        + " | file_size=" + string(global.__bpz_last_file_size));

    show_debug_message("Original board:");
    scr_print_board(board);

    var solution = scr_solve(board, 100);

    if (is_undefined(solution)) {
        show_debug_message("NO SOLUTION FOUND BY TRUE SOLVER");
        return false;
    }

    if (!scr_verify_solution(board, solution)) {
        show_debug_message("VERIFY FAILED: generated solution is not valid, .sol will not be written.");
        return false;
    }

    show_debug_message("VERIFY OK: board fully empty.");
    show_debug_message("SOLUTION FOUND");
    show_debug_message("Move count: " + string(array_length(solution)));

    var debug_board = scr_clone_board(board);

    for (var j = 0; j < array_length(solution); j++) {
        var mv = solution[j];

        var ca = debug_board[mv.r1][mv.c1];
        var cb = debug_board[mv.r2][mv.c2];

        show_debug_message(
            string(j + 1)
            + ". Swap 0-based ("
            + string(mv.r1) + "," + string(mv.c1)
            + ") with ("
            + string(mv.r2) + "," + string(mv.c2)
            + ")"
            + " | Human: row "
            + string(mv.r1 + 1) + ", col " + string(mv.c1 + 1)
            + " <-> row "
            + string(mv.r2 + 1) + ", col " + string(mv.c2 + 1)
            + " | gem "
            + string(ca.gem)
            + " <-> gem "
            + string(cb.gem)
        );

        debug_board = scr_apply_move(debug_board, mv);
    }

    var ok = scr_write_sol(sol_path, solution);

    if (ok) {
        show_debug_message("SOL FILE CREATED AT:");
        show_debug_message(sol_path);
        return true;
    }

    show_debug_message("FAILED TO SAVE SOLUTION OUTPUT");
    return false;
}
