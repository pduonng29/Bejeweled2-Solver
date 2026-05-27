function scr_path_join(path_a, path_b) {
    var result = [];

    for (var i = 0; i < array_length(path_a); i++) {
        array_push(result, path_a[i]);
    }

    for (var j = 0; j < array_length(path_b); j++) {
        array_push(result, path_b[j]);
    }

    return result;
}