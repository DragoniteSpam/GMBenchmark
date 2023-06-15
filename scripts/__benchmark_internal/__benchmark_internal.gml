function Benchmark(source_name, tests) constructor {
    self.source_name = source_name;
    self.tests = tests;
    self.name = string("[c_gray]{0}: Not yet run", source_name);
    self.runtime = undefined;
    
    self.Run = function(trials, iterations, record_results = true) {
        var color_offset = random(255);
        var best_time = infinity;
        var order = undefined;
        // Store individual timings per test and trial for advanced statistics and exporting
		var timings = array_create(array_length(self.tests), 0);
		for (var i=0, n=array_length(timings); i<n; i++) {
			timings[i] = array_create(trials, 0);
		}
		
        if (record_results) {
            self.runtime = {
                trials: trials,
                iterations: iterations,
                ms: 0
            };
        }
        
        for (var i = 0, n = array_length(self.tests); i < n; i++) {
            var test = self.tests[i];
            if (!is_instanceof(test, TestCase)) {
                show_debug_message("Benchmark {0} is not a testable case", i);
                continue;
            }
            
            test.init(iterations);
            
            if (record_results) {
                test.runtime = {
                    ms: 0,
                    per_ms: 0,
                    percentage: 0
                };
                
                // pick a random color but if it's dark, brighten it a little
                var color = make_colour_hsv((color_offset + (i - 1) / array_length(self.tests) * 255) % 255, 255, 255);
                var rr = colour_get_red(color);
                var gg = colour_get_green(color);
                var bb = colour_get_blue(color);
                
                var luma = (rr / 0xff * 0.21) + (gg / 0xff * 0.71) + (bb / 0xff * 0.08);
                // lowering the exponent will mean colors are brightened more
                luma = lerp(1, luma, power(luma, 0.96));
                rr = lerp(0xff, rr, luma);
                gg = lerp(0xff, gg, luma);
                bb = lerp(0xff, bb, luma);
                
                // blue just kinda sucks
                var blueness = bb / 0xff;
                rr = lerp(rr, 0xff, blueness * 0.15);
                gg = lerp(gg, 0xff, blueness * 0.15);
                test.color = make_colour_rgb(rr, gg, bb);
            }
        }
        
        var indices = array_create_ext(array_length(self.tests), function(index) {
            return index;
        });
        
        for (var t=0; t<trials; t++) {
            // interleave the tests
            if (order == undefined || array_length(self.tests) < 2) {
                order = array_shuffle(indices);
            } else {
                while (true) {
                    var clone = array_shuffle(indices);
                    var failed = false;
                    for (var i = 0, n = array_length(indices); i < n; i++) {
                        if (clone[i] == order[i]) {
                            failed = true;
                            break;
                        }
                    }
                    if (!failed) {
                        order = clone;
                        break;
                    }
                }
            }
            
            for (var i = 0, n = array_length(order); i < n; i++) {
                var test = self.tests[order[i]];
                if (!is_instanceof(test, TestCase)) {
                    continue;
                }
                
                var t_start = get_timer();
                test.fn(iterations);
                
                if (record_results) {
					timings[order[i]][t] = (get_timer() - t_start) / 1000;
                    test.runtime.ms += timings[order[i]][t];
                }
            }
        }
        
        if (record_results) {
            // divide the timings by the trial count
            for (var i = 0, n = array_length(self.tests); i < n; i++) {
                var test = self.tests[i];
                if (!is_instanceof(test, TestCase)) {
                    continue;
                }
                
                test.runtime.ms /= trials;
                test.runtime.per_ms = iterations / test.runtime.ms;
                best_time = min(best_time, test.runtime.ms);
                
                test.name = string("[#{0}]o[/c] {1}: {2} ms", colour_to_hex(test.color), test.source_name, test.runtime.ms);
                self.runtime.ms += test.runtime.ms;
            }
            
            // once you have the best time, you can evaluate everything else relative to it
            for (var i = 0, n = array_length(self.tests); i < n; i++) {
                var test = self.tests[i];
                test.runtime.percentage = best_time / test.runtime.ms;
            }
            
            self.SortBestToWorst();
            
            self.name = self.source_name;
        }
    };
    
    self.Reset = function() {
        for (var i = 0, n = array_length(self.tests); i < n; i++) {
            var test = self.tests[i];
            if (!is_instanceof(test, TestCase))
                continue;
            test.name = string("[c_gray]{0}", test.source_name);
            test.runtime = undefined;
        }
        self.runtime = undefined;
        self.name = self.source_name;
        self.name = string("[c_gray]{0}: Not yet run", source_name);
    };
    
    self.SortBestToWorst = function() {
        if (self.runtime == undefined)
            // did not store any results, so just ignore sorting
            return;
        
        array_sort(self.tests, function(a, b) {
            return sign(a.runtime.ms - b.runtime.ms);
        });
    };
    
    self.SortWorstToBest = function() {
        if (self.runtime == undefined)
            // did not store any results, so just ignore sorting
            return;
        
        array_sort(self.tests, function(a, b) {
            return sign(b.runtime.ms - a.runtime.ms);
        });
    };
    
    self.SortAlphabetical = function() {
        array_sort(self.tests, function(a, b) {
            return b.name < a.name;
        });
    };
}

function TestCase(name, fn, init = function() { }) constructor {
    self.name = string("[c_gray]{0}", name);
    self.source_name = name;
    self.fn = method(self, fn);
    self.init = method(self, init);
    self.runtime = undefined;
    self.color = c_white;
}

function colour_to_hex(color) {
    color = make_colour_rgb(colour_get_blue(color), colour_get_green(color), colour_get_red(color));
    return string_copy(string(ptr(color)), 11, 6);
};

function benchmark_format(value) {
    if (value < 1000) {
        return string(floor(value));
    }
    //if (value < 1_000_000) {
        return string("{0}k", floor(value div 1000));
    //}
    //return string("{0}m", floor(value div 1_000_000));
}

function benchmark_log_ceil(value) {
    var value_log = power(10, floor(log10(value)));
    return ceil(value / value_log) * value_log;
}
    
#macro Benchmarks global.__benchmarks__