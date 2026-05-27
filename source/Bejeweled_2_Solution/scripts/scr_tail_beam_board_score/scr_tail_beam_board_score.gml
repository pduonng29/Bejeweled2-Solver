function scr_tail_beam_board_score(board) {
    var total_gems = scr_count_gems(board);
    var clearable_gems = scr_count_clearable_gems(board);
    var legal_count = array_length(scr_get_legal_moves(board));
    var special_count = scr_count_specials(board);

    if (total_gems > 0 && legal_count <= 0) {
        return -999999999;
    }

    var score_value = 0;

    score_value += (8 - total_gems) * 3000000;
    score_value += (8 - clearable_gems) * 1000000;
    score_value += legal_count * 500000;
    score_value += special_count * 500000;
    score_value += scr_tail_pattern_score(board);

    if (total_gems <= 6) score_value += legal_count * 900000;
    if (total_gems <= 4) score_value += legal_count * 1300000;

    return score_value;
}
