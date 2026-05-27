function scr_choose_special_pos(group, move, board) {
    // v15 fix:
    // The .sol arrow represents an oriented move from (r1,c1) to (r2,c2).
    // When a 4/5-match creates a special gem, Bejeweled places it at the moved gem.
    // After swap, the moved gem is at destination (r2,c2), so destination must be preferred.
    if (!is_undefined(move)) {
        if (scr_group_contains_pos(group, move.r2, move.c2)) {
            var dst = board[move.r2][move.c2];

            if (dst.gem >= 0 && dst.gem <= 6 && dst.pwr == 0) {
                return [move.r2, move.c2];
            }
        }

        if (scr_group_contains_pos(group, move.r1, move.c1)) {
            var src_after_swap = board[move.r1][move.c1];

            if (src_after_swap.gem >= 0 && src_after_swap.gem <= 6 && src_after_swap.pwr == 0) {
                return [move.r1, move.c1];
            }
        }
    }

    for (var i = 0; i < array_length(group.cells); i++) {
        var p = group.cells[i];
        var r = p[0];
        var c = p[1];

        var cell = board[r][c];

        if (cell.gem >= 0 && cell.gem <= 6 && cell.pwr == 0) {
            return [r, c];
        }
    }

    return undefined;
}
