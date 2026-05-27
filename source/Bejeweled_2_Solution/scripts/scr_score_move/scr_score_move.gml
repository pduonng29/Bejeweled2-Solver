function scr_score_move(board, move) {
    var before_cells = scr_count_clearable_gems(board);
    var before_rocks = scr_count_rocks(board);
    var before_specials = scr_count_specials(board);

    var after_board = scr_apply_move(board, move);

    var after_cells = scr_count_clearable_gems(after_board);
    var after_rocks = scr_count_rocks(after_board);
    var after_specials = scr_count_specials(after_board);

    var removed_cells = before_cells - after_cells;
    var removed_rocks = before_rocks - after_rocks;
    var created_specials = after_specials - before_specials;

    var move_score = 0;

    move_score += removed_cells * 10;
    move_score += removed_rocks * 80;

    if (created_specials > 0) {
        move_score += created_specials * 40;
    }

    return move_score;
}