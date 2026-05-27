function scr_is_solved(board) {
    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            if (board[r][c].gem != GEM_EMPTY) {
                return false;
            }
        }
    }

    return true;
}