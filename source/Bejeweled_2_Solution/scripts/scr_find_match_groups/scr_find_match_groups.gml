function scr_find_match_groups(board) {
    var groups = [];

    for (var r = 0; r < BOARD_H; r++) {
        var c = 0;

        while (c < BOARD_W) {
            var g = board[r][c].gem;

            if (g < 0 || g > 6) {
                c++;
                continue;
            }

            var start = c;

            while (c + 1 < BOARD_W && board[r][c + 1].gem == g) {
                c++;
            }

            var len = c - start + 1;

            if (len >= 3) {
                var cells = [];

                for (var k = start; k <= c; k++) {
                    array_push(cells, [r, k]);
                }

                array_push(groups, {
                    color: g,
                    len: len,
                    cells: cells
                });
            }

            c++;
        }
    }


    for (var c = 0; c < BOARD_W; c++) {
        var r = 0;

        while (r < BOARD_H) {
            var g = board[r][c].gem;

            if (g < 0 || g > 6) {
                r++;
                continue;
            }

            var start = r;

            while (r + 1 < BOARD_H && board[r + 1][c].gem == g) {
                r++;
            }

            var len = r - start + 1;

            if (len >= 3) {
                var cells = [];

                for (var k = start; k <= r; k++) {
                    array_push(cells, [k, c]);
                }

                array_push(groups, {
                    color: g,
                    len: len,
                    cells: cells
                });
            }

            r++;
        }
    }

    return groups;
}