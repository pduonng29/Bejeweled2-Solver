function scr_create_empty_board() {
    var board = array_create(BOARD_H);

    for (var r = 0; r < BOARD_H; r++) {
        board[r] = array_create(BOARD_W);

        for (var c = 0; c < BOARD_W; c++) {
            board[r][c] = scr_make_cell(GEM_EMPTY, 0, 0);
        }
    }

    return board;
}