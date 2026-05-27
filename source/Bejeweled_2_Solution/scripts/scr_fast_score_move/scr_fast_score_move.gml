function scr_fast_score_move(board, move) {
    var a = board[move.r1][move.c1];
    var b = board[move.r2][move.c2];

    var s = 0;

    if (a.pwr == 1 || b.pwr == 1) {
        s += 3000;
    }


    if (a.gem == GEM_HYPER || b.gem == GEM_HYPER) {
        s += 4000;
    }

    var structural = false;

    if ((a.gem == GEM_EMPTY && b.gem != GEM_EMPTY && b.gem != GEM_ROCK)
        || (a.gem != GEM_EMPTY && a.gem != GEM_ROCK && b.gem == GEM_EMPTY)) {
        structural = true;
        s += 300;
    }

    if ((a.gem == GEM_ROCK && b.gem != GEM_EMPTY && b.gem != GEM_ROCK)
        || (a.gem != GEM_EMPTY && a.gem != GEM_ROCK && b.gem == GEM_ROCK)) {
        structural = true;
        s += 1200;
    }

    if (structural) {
        if (move.r1 == move.r2 && move.c2 == move.c1 - 1) {
            s += 800;
        }

        return s;
    }

    
    var test_board = scr_clone_board(board);
    scr_swap_cells(test_board, move.r1, move.c1, move.r2, move.c2);

    var matches = scr_find_matches(test_board);
    var match_count = array_length(matches);

    if (match_count > 0) {
        s += match_count * 1000;

        for (var i = 0; i < match_count; i++) {
            var p = matches[i];
            var r = p[0];
            var c = p[1];

            if (test_board[r][c].pwr == 1) {
                s += 5000;
            }
        }
    }

    return s;
}