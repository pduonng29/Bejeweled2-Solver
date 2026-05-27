function scr_apply_hyper_swap(board, r1, c1, r2, c2) {
    var a = board[r1][c1];
    var b = board[r2][c2];

    var target_color = -1;

    if (a.gem == GEM_HYPER && b.gem >= 0 && b.gem <= 6) {
        target_color = b.gem;
    } else if (b.gem == GEM_HYPER && a.gem >= 0 && a.gem <= 6) {
        target_color = a.gem;
    } else {
        return false;
    }

    var marked = ds_map_create();

    scr_mark_cell_with_chain(board, marked, r1, c1);
    scr_mark_cell_with_chain(board, marked, r2, c2);

    // Xóa gem cùng màu
    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            if (board[r][c].gem == target_color) {
                scr_mark_cell_with_chain(board, marked, r, c);
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

    return true;
}