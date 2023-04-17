function benchmark() {
    var tests = [];
    for (var i = 0; i < argument_count; i++) {
        var test = argument[i];
        if (!is_instanceof(test, TestCase)) {
            show_debug_message("Benchmark {0} is not a testable case", i);
            continue;
        }
        var t_start = get_timer();
        test.fn();
        test.runtime = (get_timer() - t_start) / 1000;
        show_debug_message("{0} took {1} ms", test.name, test.runtime);
        array_push(tests, test);
    }
    return tests;
}

function TestCase(name, fn) constructor {
    self.name = name;
    self.fn = fn;
    self.runtime = 0;
}

benchmark(new TestCase("array_push", function() {
    var array = [];
    repeat (100_000) {
        array_push(array, 0);
    }
}), new TestCase("ds_list_add", function() {
    var list = ds_list_create();
    repeat (100_000) {
        ds_list_add(list, 0);
    }
}));