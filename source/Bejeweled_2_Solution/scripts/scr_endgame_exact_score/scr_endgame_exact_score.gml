function scr_endgame_exact_score(board) {
    var total_gems = scr_count_gems(board);
    var clearable_gems = scr_count_clearable_gems(board);
    var rock_count = scr_count_rocks(board);

    var score_value = 0;

    score_value += (64 - total_gems) * 100000;
    score_value += (20 - clearable_gems) * 10000;
    score_value -= rock_count * 5000;

    for (var color_i = 0; color_i <= 6; color_i++) {
        var color_count = 0;
        var min_r = 999;
        var max_r = -999;
        var min_c = 999;
        var max_c = -999;

        for (var r = 0; r < BOARD_H; r++) {
            for (var c = 0; c < BOARD_W; c++) {
                if (board[r][c].gem == color_i) {
                    color_count += 1;

                    if (r < min_r) min_r = r;
                    if (r > max_r) max_r = r;
                    if (c < min_c) min_c = c;
                    if (c > max_c) max_c = c;
                }
            }
        }

        if (color_count >= 3) {
            var row_span = max_r - min_r;
            var col_span = max_c - min_c;

            score_value += 30000;
            score_value -= (row_span + col_span) * 3000;

            if (row_span == 0 || col_span == 0) {
                score_value += 50000;
            }

            if (row_span <= 1 && col_span <= 2) {
                score_value += 20000;
            }

            if (col_span <= 1 && row_span <= 2) {
                score_value += 20000;
            }
        }
    }

    return score_value;
}