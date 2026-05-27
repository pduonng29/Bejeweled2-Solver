function scr_solve(board, max_depth) {
    show_debug_message("Trying TRUE SOLVER Portfolio v18: RAM-safe + rule-complete fallback...");
    show_debug_message("Max steps: " + string(max_depth));

    var result;

    // v18 policy:
    // - Do not run heavy solvers repeatedly. v17 could call Small DFS many times and
    //   push RAM to 15GB-25GB on levels such as Nhom4 08/13/15.
    // - Exact Priority runs first, but with a strict frontier/tail cap.
    // - Mixed Beam is only a light fallback.
    // - Greedy fallback remains verify-required.

    show_debug_message("Pass 1: Exact Priority FIRST v18 RAM-CAPPED...");
    result = scr_exact_priority_solve(board, 90, 12000, 12000);
    if (!is_undefined(result)) return result;

    show_debug_message("Pass 2: Small-board exact probe v18 if applicable...");
    result = scr_small_board_bfs_solve(board, 16, 6000, 2500);
    if (!is_undefined(result)) return result;

    show_debug_message("Pass 3: Mixed Beam LIGHT v18 fallback...");
    result = scr_mixed_beam_solve(board, 90, 16, 6, 7000);
    if (!is_undefined(result)) return result;

    show_debug_message("Pass 4: Greedy fallback, verify required...");
    result = scr_try_greedy_solve_light(board, max_depth);
    if (!is_undefined(result)) return result;

    show_debug_message("TRUE SOLVER Portfolio v18 failed.");
    return undefined;
}
