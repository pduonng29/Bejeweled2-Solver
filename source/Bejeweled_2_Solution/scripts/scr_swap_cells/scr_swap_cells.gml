function scr_swap_cells(board, r1, c1, r2, c2) {
    var temp = board[r1][c1];
    board[r1][c1] = board[r2][c2];
    board[r2][c2] = temp;
}