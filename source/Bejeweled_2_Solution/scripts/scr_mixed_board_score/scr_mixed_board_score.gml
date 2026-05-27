function scr_mixed_board_score(board) {
    var total_gems = scr_count_gems(board);
    var clearable_gems = scr_count_clearable_gems(board);
    var special_count = scr_count_specials(board);
    var legal_count = array_length(scr_get_legal_moves(board));

    if (total_gems > 0 && legal_count <= 0) {
        return -999999999;
    }

    var score_value = 0;

    score_value += (64 - total_gems) * 1000000;
    score_value += (64 - clearable_gems) * 300000;
    score_value += special_count * 120000;
    score_value += legal_count * 50000;

    if (total_gems <= 12) score_value += legal_count * 150000;
    if (total_gems <= 8) score_value += legal_count * 500000;
    if (total_gems <= 6) score_value += legal_count * 800000;
    if (total_gems <= 4) score_value += legal_count * 1200000;

    return score_value;
}
