function scr_apply_gravity(board) {
    for (var c = 0; c < BOARD_W; c++) {
        var write_r = BOARD_H - 1;

        for (var r = BOARD_H - 1; r >= 0; r--) {
            if (board[r][c].gem != GEM_EMPTY) {
                if (write_r != r) {
                    board[write_r][c] = board[r][c];
                    board[r][c] = scr_make_cell(GEM_EMPTY, 0, 0);
                }

                write_r--;
            }
        }
    }
}