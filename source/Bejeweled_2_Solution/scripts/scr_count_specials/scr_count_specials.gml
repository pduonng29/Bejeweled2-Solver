function scr_count_specials(board) {
    var count = 0;

    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            var cell = board[r][c];

            if (cell.pwr == 1 || cell.gem == GEM_HYPER || cell.gem == GEM_BOMB) {
                count++;
            }
        }
    }

    return count;
}