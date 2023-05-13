function Benchmark() constructor {
    self.source_name = argument[0];
    self.tests = [];
    self.runtime = 0;
    
    var color_offset = random(255);
    
    for (var i = 1; i < argument_count; i++) {
        var test = argument[i];
        if (!is_instanceof(test, TestCase)) {
            show_debug_message("Benchmark {0} is not a testable case", i);
            continue;
        }
        var t_start = get_timer();
        test.fn();
        test.runtime = {
            ms: (get_timer() - t_start) / 1000,
            per_ms: 0,
            percentage: 0
        };
        test.runtime.per_ms = 0;    // todo
        
        test.color = make_colour_hsv((color_offset + (i - 1) / (argument_count - 1) * 255) % 255, 255, 255);
        test.name = string("[#{0}]o[/c] {1}: {2} ms", colour_to_hex(test.color), test.source_name, test.runtime.ms);
        self.runtime += test.runtime.ms;
        array_push(self.tests, test);
    }
    self.name = string("{0}: {1} ms", self.source_name, self.runtime);
    
    self.SortBestToWorst = function() {
        array_sort(self.tests, function(a, b) {
            return sign(a.runtime.ms - b.runtime.ms);
        });
    };
    
    self.SortWorstToBest = function() {
        array_sort(self.tests, function(a, b) {
            return sign(b.runtime.ms - a.runtime.ms);
        });
    };
    
    self.SortAlphabetical = function() {
        array_sort(self.tests, function(a, b) {
            return b.name < a.name;
        });
    };
    
    self.SortBestToWorst();
}

function TestCase(name, fn) constructor {
    self.name = name;
    self.source_name = name;
    self.fn = fn;
    self.runtime = undefined;
    self.color = c_white;
}

function colour_to_hex(color) {
    color = make_colour_rgb(colour_get_blue(color), colour_get_green(color), colour_get_red(color));
    return string_copy(string(ptr(color)), 11, 6);
};

#macro Benchmarks global.__benchmarks__