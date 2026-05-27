function scr_endgame_state_score(board) {
    var clearable = scr_count_clearable_gems(board);

    if (clearable == 0) {
        return 9999999;
    }

    var first_gem = -999;
    var same_type = true;

    var min_r = 999;
    var max_r = -999;
    var min_c = 999;
    var max_c = -999;

    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            var cell = board[r][c];

            if ((cell.gem >= 0 && cell.gem <= 6) || cell.gem == GEM_HYPER || cell.gem == GEM_BOMB) {
                if (first_gem == -999) {
                    first_gem = cell.gem;
                } else {
                    if (cell.gem != first_gem) {
                        same_type = false;
                    }
                }

                if (r < min_r) min_r = r;
                if (r > max_r) max_r = r;
                if (c < min_c) min_c = c;
                if (c > max_c) max_c = c;
            }
        }
    }

    var state_score = 0;

    state_score += (10 - clearable) * 10000;

    if (same_type) {
        state_score += 5000;
    }

    var row_span = max_r - min_r;
    var col_span = max_c - min_c;

    state_score -= (row_span + col_span) * 1000;

    if (row_span == 0 || col_span == 0) {
        state_score += 20000;
    }

    if (row_span <= 1 && col_span <= 2) {
        state_score += 8000;
    }

    return state_score;
}