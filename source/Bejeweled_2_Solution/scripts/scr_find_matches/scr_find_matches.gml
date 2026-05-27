function scr_find_matches(board) {
    var marked = ds_map_create();

    // Match ngang
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
                for (var k = start; k <= c; k++) {
                    scr_mark_cell_with_chain(board, marked, r, k);
                }
            }

            c++;
        }
    }

    // Match dọc
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
                for (var k = start; k <= r; k++) {
                    scr_mark_cell_with_chain(board, marked, k, c);
                }
            }

            r++;
        }
    }

    var result = [];
    var key = ds_map_find_first(marked);

    while (!is_undefined(key)) {
        array_push(result, marked[? key]);
        key = ds_map_find_next(marked, key);
    }

    ds_map_destroy(marked);

    return result;
}