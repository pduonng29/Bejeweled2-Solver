function scr_mark_cell_with_chain(board, marked, r, c) {
    if (!scr_inside_board(r, c)) return;

    var key = string(r) + "," + string(c);

    if (ds_map_exists(marked, key)) {
        return;
    }

    ds_map_set(marked, key, [r, c]);

    var cell = board[r][c];

    if (cell.pwr == 1 || cell.gem == GEM_BOMB) {
        for (var dr = -1; dr <= 1; dr++) {
            for (var dc = -1; dc <= 1; dc++) {
                var rr = r + dr;
                var cc = c + dc;

                if (scr_inside_board(rr, cc)) {
                    scr_mark_cell_with_chain(board, marked, rr, cc);
                }
            }
        }
    }
}