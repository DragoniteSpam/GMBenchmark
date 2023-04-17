function Benchmark() constructor {
    self.source_name = argument[0];
    self.tests = [];
    self.runtime = 0;
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
        self.runtime += test.runtime;
        array_push(self.tests, test);
    }
    self.name = string("{0}: {1} ms", self.source_name, self.runtime);
    
    self.SortBestToWorst = function() {
        array_sort(self.tests, function(a, b) {
            return sign(a.runtime - b.runtime);
        });
    };
    
    self.SortWorstToBest = function() {
        array_sort(self.tests, function(a, b) {
            return sign(b.runtime - a.runtime);
        });
    };
    
    self.SortAlphabetical = function() {
        array_sort(self.tests, function(a, b) {
            return b.name < a.name;
        });
    };
}

function TestCase(name, fn) constructor {
    self.name = name;
    self.source_name = name;
    self.fn = fn;
    self.runtime = 0;
}

#macro Benchmarks global.__benchmarks__