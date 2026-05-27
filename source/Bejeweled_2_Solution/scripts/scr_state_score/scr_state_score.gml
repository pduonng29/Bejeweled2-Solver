function scr_state_score(board) {
    var cells = scr_count_clearable_gems(board);
    var rocks = scr_count_rocks(board);
    var specials = scr_count_specials(board);

    var state_score = 0;

    state_score += (64 - cells) * 100;
    state_score += (10 - rocks) * 1000;
    state_score += specials * 120;

    return state_score;
}