function scr_count_clearable_gems(board) {
    var count = 0;

    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            var cell = board[r][c];

            if (cell.gem >= 0 && cell.gem <= 6) {
                count++;
            }

            if (cell.gem == GEM_HYPER || cell.gem == GEM_BOMB) {
                count++;
            }
        }
    }

    return count;
}