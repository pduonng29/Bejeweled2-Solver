function scr_tail_color_viable(board) {
    var total = scr_count_gems(board);

    if (total <= 0) {
        return true;
    }

    if (total > 8) {
        return true;
    }

    var counts = [];
    for (var i = 0; i < 7; i++) {
        counts[i] = 0;
    }

    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            var g = board[r][c].gem;

            if (g == GEM_EMPTY) {
                continue;
            }

            if (g == GEM_ROCK) {
                continue;
            }

            if (g == GEM_HYPER) {
                return true;
            }

            if (g >= 0 && g <= 6) {
                counts[g] += 1;
            }
        }
    }

    for (var k = 0; k < 7; k++) {
        if (counts[k] >= 3) {
            return true;
        }
    }

    return false;
}