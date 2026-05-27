function scr_is_color_gem_cell(cell) {
    return cell.gem >= 0 && cell.gem <= 6;
}

function scr_is_block_or_empty_cell(cell) {
    return cell.gem == GEM_EMPTY || cell.gem == GEM_ROCK;
}

function scr_match_group_contains_cell(groups, rr_check, cc_check) {
    for (var gi = 0; gi < array_length(groups); gi++) {
        var group = groups[gi];

        for (var ci = 0; ci < array_length(group.cells); ci++) {
            var p = group.cells[ci];
            var rr = p[0];
            var cc = p[1];

            if (rr == rr_check && cc == cc_check) {
                return true;
            }
        }
    }

    return false;
}

function scr_move_has_related_match(groups, mv) {
    if (scr_match_group_contains_cell(groups, mv.r1, mv.c1)) return true;
    if (scr_match_group_contains_cell(groups, mv.r2, mv.c2)) return true;
    return false;
}

function scr_is_real_legal_move(board, mv) {
    if (mv.r1 < 0 || mv.r1 >= BOARD_H || mv.r2 < 0 || mv.r2 >= BOARD_H) return false;
    if (mv.c1 < 0 || mv.c1 >= BOARD_W || mv.c2 < 0 || mv.c2 >= BOARD_W) return false;

    var dr = abs(mv.r1 - mv.r2);
    var dc = abs(mv.c1 - mv.c2);
    if (dr + dc != 1) return false;

    var a = board[mv.r1][mv.c1];
    var b = board[mv.r2][mv.c2];

    // Hai ô hoàn toàn giống nhau thì swap không tạo thay đổi thực tế.
    if (a.gem == b.gem && a.pwr == b.pwr && a.value == b.value) return false;

    // Empty/Rock không tự swap với nhau.
    if (scr_is_block_or_empty_cell(a) && scr_is_block_or_empty_cell(b)) return false;

    // Hyper + gem màu là nước đi đặc biệt hợp lệ, dù không tạo match 3 thông thường.
    if (a.gem == GEM_HYPER && scr_is_color_gem_cell(b)) return true;
    if (b.gem == GEM_HYPER && scr_is_color_gem_cell(a)) return true;

    var tb = scr_clone_board(board);
    scr_swap_cells(tb, mv.r1, mv.c1, mv.r2, mv.c2);

    var groups = scr_find_match_groups(tb);
    if (array_length(groups) <= 0) return false;

    // Luật quan trọng: match phải liên quan đến vị trí sau swap của ít nhất 1 gem vừa di chuyển.
    // Nếu swap gem với empty/rock, gem đổi sang ô còn lại nên phải kiểm tra vị trí mới của gem.
    if (a.gem == GEM_EMPTY || a.gem == GEM_ROCK) {
        if (scr_is_color_gem_cell(b)) {
            return scr_match_group_contains_cell(groups, mv.r1, mv.c1);
        }
        return false;
    }

    if (b.gem == GEM_EMPTY || b.gem == GEM_ROCK) {
        if (scr_is_color_gem_cell(a)) {
            return scr_match_group_contains_cell(groups, mv.r2, mv.c2);
        }
        return false;
    }

    return scr_move_has_related_match(groups, mv);
}
