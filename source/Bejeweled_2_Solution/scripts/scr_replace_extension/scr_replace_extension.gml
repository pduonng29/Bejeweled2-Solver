function scr_replace_extension(path, new_ext) {
    var len = string_length(path);

    for (var i = len; i >= 1; i--) {
        if (string_char_at(path, i) == ".") {
            return string_copy(path, 1, i - 1) + new_ext;
        }
    }

    return path + new_ext;
}