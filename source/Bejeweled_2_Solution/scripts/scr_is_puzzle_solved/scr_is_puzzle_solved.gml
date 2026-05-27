function scr_is_puzzle_solved(board) {
    return scr_count_clearable_gems(board) == 0;
}