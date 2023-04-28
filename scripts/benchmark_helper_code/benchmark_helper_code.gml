function split(str, delimiter = " ", enqueue_blank = false) {
    var queue = ds_queue_create();
    var tn = "";
    
    str += string_char_at(delimiter, 1);         // lazy way of ensuring the last term in the list does not get skipped
    
    for (var i = 1; i <= string_length(str); i++) {
        var c = string_char_at(str, i);
        var previous = string_char_at(str, i - 1);
        var is_break_char = false;
        for (var j = 1; j <= string_length(delimiter); j++) {
            if (string_char_at(delimiter, j) == c && previous != "\\") {
                if (string_length(tn) > 0 || enqueue_blank) {
                    ds_queue_enqueue(queue, tn);
                }
                tn = "";
                is_break_char = true;
                break;
            }
        }
        if (!is_break_char) tn = tn + c;
    }
    
    // because i did a dumb way of adding the first term
    if (ds_queue_size(queue) == 1 && string_length(ds_queue_head(queue)) == 0) {
        ds_queue_clear(queue);
    }
    
    return queue;
}