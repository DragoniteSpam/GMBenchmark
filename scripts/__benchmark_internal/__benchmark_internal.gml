function Benchmark(source_name, tests) constructor {
    self.source_name = source_name;
    self.tests = tests;
    self.name = string("[c_gray]{0}: Not yet run", source_name);
    self.runtime = undefined;
    
    self.Run = function(trials, iterations, record_results = true) {
        var best_time = infinity;
        var order = undefined;
        
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
                
                static hue_buffer_red = 30;
                static hue_buffer_blue = 30;
                
                var hue = (hue_buffer_red + i / array_length(self.tests) * (255 - hue_buffer_red - hue_buffer_blue)) % 255;
                var color = make_colour_hsv(hue, 255, 255);
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
        
        repeat (trials) {
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
                    test.runtime.ms += (get_timer() - t_start) / 1000;
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

function benchmark_write_results_csv(filename) {
	var output = buffer_create(1000, buffer_grow, 1);
	
	for (var i = 0, n = array_length(Benchmarks); i < n; i++) {
		var benchmark = Benchmarks[i];
		if (benchmark.runtime == undefined) continue;
		
		buffer_write(output, buffer_text, $"{string_replace_all(benchmark.source_name, ",", " ")},Trials:,{benchmark.runtime.trials},Iterations per trial:,{benchmark.runtime.iterations}");
		
		buffer_write(output, buffer_text, "\n");
		buffer_write(output, buffer_text, "Total time");
		for (var j = 0, n2 = array_length(benchmark.tests); j < n2; j++) {
			buffer_write(output, buffer_text, "," + string_replace_all(benchmark.tests[j].source_name, ",", " "));
		}
		buffer_write(output, buffer_text, "\n");
		
		buffer_write(output, buffer_text, string(benchmark.runtime.ms));
		for (var j = 0, n2 = array_length(benchmark.tests); j < n2; j++) {
			var runtime = benchmark.tests[j].runtime;
			buffer_write(output, buffer_text, "," + string(runtime.ms));
		}
		buffer_write(output, buffer_text, "\n");
		
		buffer_write(output, buffer_text, "Relative performance:");
		for (var j = 0, n2 = array_length(benchmark.tests); j < n2; j++) {
			var runtime = benchmark.tests[j].runtime;
			buffer_write(output, buffer_text, "," + string(runtime.percentage));
		}
		buffer_write(output, buffer_text, "\n");
		
		buffer_write(output, buffer_text, "Per ms:");
		for (var j = 0, n2 = array_length(benchmark.tests); j < n2; j++) {
			var runtime = benchmark.tests[j].runtime;
			buffer_write(output, buffer_text, "," + string(runtime.per_ms));
		}
		buffer_write(output, buffer_text, "\n\n");
	}
	
	buffer_save_ext(output, filename, 0, buffer_tell(output));
	buffer_delete(output);
}

function benchmark_write_results_text(filename, tests) {
    var file = file_text_open_write(filename);
    file_text_write_string(file, $"GMBenchmark - {array_length(tests)} benchmarks run");
    // \n messes up template strings lol
    file_text_writeln(file);
    file_text_writeln(file);
    
    for (var i = 0, count = array_length(tests); i < count; i++) {
        var benchmark = tests[i].benchmark;
        
        file_text_write_string(file, $"{benchmark.source_name}");
        file_text_writeln(file);
        file_text_write_string(file, $"    Trial count: {benchmark.runtime.trials}");
        file_text_writeln(file);
        file_text_write_string(file, $"    Iteration count: {benchmark.runtime.iterations}");
        file_text_writeln(file);
        file_text_write_string(file, $"    Runtime: {benchmark.runtime.ms}");
        file_text_writeln(file);
        file_text_writeln(file);
        
        file_text_write_string(file, $"    Tests: {array_length(benchmark.tests)}");
        file_text_writeln(file);
        
        for (var j = 0, test_count = array_length(benchmark.tests); j < test_count; j++) {
            var test = benchmark.tests[j];
            
            file_text_write_string(file, $"        {test.source_name}: {test.runtime.ms} ms ({test.runtime.percentage}% of the total)");
            file_text_writeln(file);
        }
        
        file_text_writeln(file);
    }
    
    file_text_close(file);
}
    
#macro Benchmarks global.__benchmarks__

function deal_with_cmd_args(args) {
    var results = "";
    var kill = true;
    var n = array_length(args);
    
    var tests = [];
    
    for (var i = 0; i < n; i++) {
        switch (args[i]) {
            case "-file":
                if (i < n - 1) {
                    results = args[i + 1];
                }
                break;
            case "-dontkill":
                kill = false;
                break;
            
            case "-trials":
                if (array_length(tests) > 0 && i < n - 1) {
                    array_last(tests).trials = real(args[i + 1]);
                }
                break;
            case "-iter":
                if (array_length(tests) > 0 && i < n - 1) {
                    array_last(tests).iterations = real(args[i + 1]);
                }
                break;
            
            default:
                for (var j = 0; j < array_length(Benchmarks); j++) {
                    if (Benchmarks[j].source_name == args[i]) {
                        array_push(tests, {
                            benchmark: Benchmarks[j],
                            trials: 4,
                            iterations: 100_000
                        });
                    }
                }
                break;
        }
    }
    
    if (array_length(tests) > 0) {
        array_foreach(tests, function(test) {
            test.benchmark.Run(test.trials, test.iterations);
        });
        
        if (results != "") {
            var filename = $"{program_directory}/{results}";
            
            if (filename_ext(results) == ".csv") {
                benchmark_write_results_csv(filename);
            } else {
                benchmark_write_results_text(filename, tests);
            }
        }
        
        if (kill) {
            game_end();
        }
    }
}