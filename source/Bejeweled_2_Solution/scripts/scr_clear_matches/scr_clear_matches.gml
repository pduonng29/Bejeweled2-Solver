function scr_clear_matches(board, matches) {
    for (var i = 0; i < array_length(matches); i++) {
        var pos = matches[i];

        var r = pos[0];
        var c = pos[1];

        board[r][c] = scr_make_cell(GEM_EMPTY, 0, 0);
    }
}