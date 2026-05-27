function scr_inside_board(r, c) {
    return r >= 0 && r < BOARD_H && c >= 0 && c < BOARD_W;
}