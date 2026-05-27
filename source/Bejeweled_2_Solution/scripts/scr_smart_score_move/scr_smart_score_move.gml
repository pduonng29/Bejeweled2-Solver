function scr_smart_score_move(board, move) {
    var before_cells = scr_count_gems(board);
    var before_rocks = scr_count_rocks(board);
    var before_specials = scr_count_specials(board);

    var after_board = scr_apply_move(board, move);

    var after_cells = scr_count_gems(after_board);
    var after_rocks = scr_count_rocks(after_board);
    var after_specials = scr_count_specials(after_board);

    var removed_cells = before_cells - after_cells;
    var removed_rocks = before_rocks - after_rocks;
    var created_specials = after_specials - before_specials;

    var a = board[move.r1][move.c1];
    var b = board[move.r2][move.c2];

    var mv_score = 0;


    mv_score += removed_cells * 1000;

    mv_score += removed_rocks * 5000;

    // Tạo Power/Hyper
    if (created_specials > 0) {
        mv_score += created_specials * 800;
    }

   
    if (scr_move_is_empty_slide(board, move)) {
        mv_score += 100;
    }

    if ((a.gem == GEM_ROCK && b.gem != GEM_EMPTY && b.gem != GEM_ROCK)
        || (a.gem != GEM_EMPTY && a.gem != GEM_ROCK && b.gem == GEM_ROCK)) {
        mv_score += 700;
    }

    if (a.gem == GEM_HYPER || b.gem == GEM_HYPER) {
        mv_score += 1500;
    }

    if (a.pwr == 1 || b.pwr == 1) {
        mv_score += 1000;
    }

    return mv_score;
}