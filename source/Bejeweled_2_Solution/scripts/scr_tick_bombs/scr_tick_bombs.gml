function scr_tick_bombs(board) {
    var marked = ds_map_create();
    var exploded = false;

    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            if (board[r][c].gem == GEM_BOMB) {
                board[r][c].value -= 1;

                if (board[r][c].value <= 0) {
                    exploded = true;
                    scr_mark_cell_with_chain(board, marked, r, c);
                }
            }
        }
    }

    var key = ds_map_find_first(marked);

    while (!is_undefined(key)) {
        var pos = marked[? key];
        var rr = pos[0];
        var cc = pos[1];

        board[rr][cc] = scr_make_cell(GEM_EMPTY, 0, 0);

        key = ds_map_find_next(marked, key);
    }

    ds_map_destroy(marked);

    return exploded;
}