function scr_tail_pattern_score(board) {
    var score_value = 0;

    for (var gcol = 0; gcol <= 6; gcol++) {
        var pos = [];

        for (var r = 0; r < BOARD_H; r++) {
            for (var c = 0; c < BOARD_W; c++) {
                if (board[r][c].gem == gcol) {
                    array_push(pos, [r, c]);
                }
            }
        }

        var n = array_length(pos);

        if (n >= 3) {
            score_value += 4000000;

            var dist_sum = 0;
            var adj_pairs = 0;

            for (var i = 0; i < n; i++) {
                for (var j = i + 1; j < n; j++) {
                    var r1 = pos[i][0];
                    var c1 = pos[i][1];
                    var r2 = pos[j][0];
                    var c2 = pos[j][1];

                    var md = abs(r1 - r2) + abs(c1 - c2);

                    dist_sum += md;

                    if (md == 1) {
                        adj_pairs += 1;
                    }
                }
            }

            score_value += adj_pairs * 2500000;
            score_value -= dist_sum * 250000;
        }
    }

    return score_value;
}