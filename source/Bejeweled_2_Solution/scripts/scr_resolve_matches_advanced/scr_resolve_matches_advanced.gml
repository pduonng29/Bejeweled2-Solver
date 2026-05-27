function scr_merge_match_groups_v18(groups) {
    var merged = [];

    for (var i = 0; i < array_length(groups); i++) {
        var g = groups[i];
        var added = false;

        for (var mi = 0; mi < array_length(merged); mi++) {
            var mg = merged[mi];
            if (mg.color != g.color) continue;

            var overlaps = false;
            for (var a = 0; a < array_length(g.cells); a++) {
                var p = g.cells[a];
                for (var b = 0; b < array_length(mg.cells); b++) {
                    var q = mg.cells[b];
                    if (p[0] == q[0] && p[1] == q[1]) {
                        overlaps = true;
                        break;
                    }
                }
                if (overlaps) break;
            }

            if (overlaps) {
                // Add missing cells from g into merged group.
                for (var ca = 0; ca < array_length(g.cells); ca++) {
                    var gp = g.cells[ca];
                    var exists = false;
                    for (var cb = 0; cb < array_length(mg.cells); cb++) {
                        var mp = mg.cells[cb];
                        if (gp[0] == mp[0] && gp[1] == mp[1]) {
                            exists = true;
                            break;
                        }
                    }
                    if (!exists) array_push(mg.cells, gp);
                }
                mg.len = array_length(mg.cells);
                if (g.len >= 5) mg.straight5 = true;
                merged[mi] = mg;
                added = true;
                break;
            }
        }

        if (!added) {
            array_push(merged, {
                color: g.color,
                len: g.len,
                cells: g.cells,
                straight5: (g.len >= 5)
            });
        }
    }

    return merged;
}

function scr_resolve_matches_advanced(board, move) {
    var groups = scr_merge_match_groups_v18(scr_find_match_groups(board));

    if (array_length(groups) == 0) {
        return false;
    }

    var marked = ds_map_create();
    var create_special = ds_map_create();

    for (var i = 0; i < array_length(groups); i++) {
        var group = groups[i];
        var has_existing_power = false;

        for (var a = 0; a < array_length(group.cells); a++) {
            var pp = group.cells[a];
            var rr0 = pp[0];
            var cc0 = pp[1];
            if (board[rr0][cc0].pwr == 1 || board[rr0][cc0].gem == GEM_HYPER || board[rr0][cc0].gem == GEM_BOMB) {
                has_existing_power = true;
            }
        }

        var special_pos = undefined;
        var special_type = -1;

        if (!has_existing_power) {
            if (group.straight5) {
                // Straight 5 creates Hyper Gem.
                special_pos = scr_choose_special_pos(group, move, board);
                special_type = GEM_HYPER;
            } else if (group.len >= 4) {
                // 4-match or merged L/T-style match creates a Power Gem, not Hyper.
                special_pos = scr_choose_special_pos(group, move, board);
                special_type = 1;
            }
        }

        var special_key = "";
        if (!is_undefined(special_pos)) {
            special_key = scr_pos_key(special_pos[0], special_pos[1]);
        }

        for (var j = 0; j < array_length(group.cells); j++) {
            var p = group.cells[j];
            var r = p[0];
            var c = p[1];
            var key = scr_pos_key(r, c);
            if (key == special_key) continue;
            scr_mark_cell_with_chain(board, marked, r, c);
        }

        if (!is_undefined(special_pos)) {
            var data;
            if (special_type == GEM_HYPER) {
                data = { r: special_pos[0], c: special_pos[1], gem: GEM_HYPER, pwr: 0, value: 0 };
            } else {
                data = { r: special_pos[0], c: special_pos[1], gem: group.color, pwr: 1, value: 0 };
            }
            ds_map_set(create_special, special_key, data);
        }
    }

    var key2 = ds_map_find_first(marked);
    while (!is_undefined(key2)) {
        var pos = marked[? key2];
        var rr = pos[0];
        var cc = pos[1];
        board[rr][cc] = scr_make_cell(GEM_EMPTY, 0, 0);
        key2 = ds_map_find_next(marked, key2);
    }

    var ckey = ds_map_find_first(create_special);
    while (!is_undefined(ckey)) {
        var d = create_special[? ckey];
        board[d.r][d.c] = scr_make_cell(d.gem, d.pwr, d.value);
        ckey = ds_map_find_next(create_special, ckey);
    }

    ds_map_destroy(marked);
    ds_map_destroy(create_special);
    return true;
}
