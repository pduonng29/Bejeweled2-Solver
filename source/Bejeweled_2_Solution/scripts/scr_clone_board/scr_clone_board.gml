function scr_clone_board(board) {
    var b = array_create(BOARD_H);

    for (var r = 0; r < BOARD_H; r++) {
        b[r] = array_create(BOARD_W);

        for (var c = 0; c < BOARD_W; c++) {
            var cell = board[r][c];

            b[r][c] = scr_make_cell(
                cell.gem,
                cell.pwr,
                cell.value
            );
        }
    }

    return b;
}