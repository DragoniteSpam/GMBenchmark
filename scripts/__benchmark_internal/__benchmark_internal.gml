function Benchmark() constructor {
    self.name = argument[0];
    self.tests = [];
    for (var i = 1; i < argument_count; i++) {
        var test = argument[i];
        if (!is_instanceof(test, TestCase)) {
            show_debug_message("Benchmark {0} is not a testable case", i);
            continue;
        }
        var t_start = get_timer();
        test.fn();
        test.runtime = (get_timer() - t_start) / 1000;
        test.name = string("{0}: {1} ms", test.source_name, test.runtime);
        show_debug_message(test.name);
        array_push(self.tests, test);
    }
}

function TestCase(name, fn) constructor {
    self.name = name;
    self.source_name = name;
    self.fn = fn;
    self.runtime = 0;
}

#macro Benchmarks global.__benchmarks__