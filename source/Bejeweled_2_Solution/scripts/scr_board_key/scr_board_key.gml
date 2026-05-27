function scr_board_key(board) {
    var key = "";

    for (var r = 0; r < BOARD_H; r++) {
        for (var c = 0; c < BOARD_W; c++) {
            var cell = board[r][c];

            key += string(cell.gem);
            key += ":";
            key += string(cell.pwr);
            key += ":";
            key += string(cell.value);
            key += "|";
        }
    }

    return key;
}