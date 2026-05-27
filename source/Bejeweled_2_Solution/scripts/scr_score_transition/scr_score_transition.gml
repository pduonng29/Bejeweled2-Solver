function scr_score_transition(before_board, after_board, move) {
    var before_cells = scr_count_clearable_gems(before_board);
    var after_cells = scr_count_clearable_gems(after_board);

    var before_rocks = scr_count_rocks(before_board);
    var after_rocks = scr_count_rocks(after_board);

    var before_specials = scr_count_specials(before_board);
    var after_specials = scr_count_specials(after_board);

    var removed_cells = before_cells - after_cells;
    var removed_rocks = before_rocks - after_rocks;
    var created_specials = after_specials - before_specials;

    var a = before_board[move.r1][move.c1];
    var b = before_board[move.r2][move.c2];

    var s = 0;

    s += removed_cells * 1000;
    s += removed_rocks * 5000;

    if (created_specials > 0) {
        s += created_specials * 800;
    }

    if ((a.gem == GEM_EMPTY && b.gem != GEM_EMPTY && b.gem != GEM_ROCK)
        || (a.gem != GEM_EMPTY && a.gem != GEM_ROCK && b.gem == GEM_EMPTY)) {
        s += 150;
    }

    if ((a.gem == GEM_ROCK && b.gem != GEM_EMPTY && b.gem != GEM_ROCK)
        || (a.gem != GEM_EMPTY && a.gem != GEM_ROCK && b.gem == GEM_ROCK)) {
        s += 1200;
    }

    if (a.pwr == 1 || b.pwr == 1) {
        s += 1000;
    }

    if (a.gem == GEM_HYPER || b.gem == GEM_HYPER) {
        s += 1500;
    }

    return s;
}