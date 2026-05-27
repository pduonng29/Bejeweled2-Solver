function scr_count_gems(board) {
    var count = 0;

    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            if (board[r][c].gem != GEM_EMPTY) {
                count++;
            }
        }
    }

    return count;
}