function scr_print_board(board) {
    show_debug_message("----- BOARD -----");

    for (var r = 0; r < BOARD_H; r++) {
        var line = "";

        for (var c = 0; c < BOARD_W; c++) {
            var cell = board[r][c];
            var g = cell.gem;

            if (g == GEM_EMPTY) {
                line += ". ";
            } else if (g == GEM_BOMB) {
                line += "B" + string(cell.value) + " ";
            } else if (g == GEM_ROCK) {
                line += "R ";
            } else if (g == GEM_HYPER) {
                line += "H ";
            } else if (cell.pwr == 1) {
                line += "P" + string(g) + " ";
            } else {
                line += string(g) + " ";
            }
        }

        show_debug_message(line);
    }
}