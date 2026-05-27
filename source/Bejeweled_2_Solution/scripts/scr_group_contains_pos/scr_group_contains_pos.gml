function scr_group_contains_pos(group, r, c) {
    for (var i = 0; i < array_length(group.cells); i++) {
        var p = group.cells[i];

        if (p[0] == r && p[1] == c) {
            return true;
        }
    }

    return false;
}