function scr_controlled_beam_score(board) {
    var total_gems = scr_count_gems(board);
    var clearable_gems = scr_count_clearable_gems(board);
    var legal_moves = scr_get_legal_moves(board);
    var legal_count = array_length(legal_moves);
    var special_count = scr_count_specials(board);

    if (total_gems > 0 && legal_count <= 0) {
        return -999999999;
    }

    var survivor_count = scr_controlled_survivor_count(board, 8);

    var score_value = 0;

    score_value += (64 - total_gems) * 800000;
    score_value += (64 - clearable_gems) * 250000;
    score_value += legal_count * 1000000;
    score_value += survivor_count * 1500000;
    score_value += special_count * 150000;

    if (total_gems <= 12) {
        score_value += legal_count * 1500000;
        score_value += survivor_count * 2500000;
    }

    if (total_gems <= 8) {
        score_value += legal_count * 2000000;
        score_value += survivor_count * 3500000;
    }

    if (total_gems > 0 && legal_count <= 1) {
        score_value -= 12000000;
    }

    if (total_gems > 0 && survivor_count <= 0) {
        score_value -= 20000000;
    }

    return score_value;
}