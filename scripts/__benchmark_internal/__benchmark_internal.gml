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
            
			// Store test names for file export
			var test_names = [];
            for (var i = 0, n = array_length(order); i < n; i++) {
				array_push(test_names, self.tests[i].source_name);
				
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
			
			// Export timings to file
			if (obj_main.export_results_checkbox.value) {				
				benchmark_export(self.name, test_names, timings);
			}
			
			// ANOVA test
			obj_main.anova_result = anova_test(timings);
        }
		
		window_set_cursor(cr_default);
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

function get_date_string() {
	var yyyy = date_get_year(date_current_datetime());
	var m = date_get_month(date_current_datetime());
	var d = date_get_day(date_current_datetime());
	return string("{0}{1}{2}{3}{4}", yyyy, m<10 ? "0" : "", m, d<10 ? "0" : "", d);
}

function get_time_string() {
	var h = date_get_hour(date_current_datetime());
	var m = date_get_minute(date_current_datetime());
	var s = date_get_second(date_current_datetime());
	return string("{0}{1}{2}{3}{4}{5}", h<10 ? "0" : "", h, m<10 ? "0" : "", m, s<10 ? "0" : "", s);
}

function benchmark_export(suite_name, test_names, timings) {
	try {
		var fid = file_text_open_write(string("GMBenchmark_{0}_{1}_{2}{3}", suite_name, get_date_string(), get_time_string(), FILE_EXTENSION));
		
		// Export header
		var str = string_join(FILE_DELIMITER, "Trial #", string_join_ext(FILE_DELIMITER, test_names)+"\n");
		file_text_write_string(fid, str);
		
		for (var trial = 0, m = array_length(timings[0]); trial < m; trial++) {
			
			str = string(trial+1);
			
			for (var test = 0, n = array_length(timings); test < n; test++) {				
				str += string("{0}{1}", FILE_DELIMITER, timings[test][trial]);
			}
			
			file_text_write_string(fid, str+"\n");
		}
		
		file_text_close(fid);
	}
	catch (exception) {
		show_debug_message("WARNING: error exporting results to file.");
	}
}

function anova_test(timings) {
	// Compute average timings per test and global average
	var global_average = 0;
	var averages = [];
	var tests = array_length(timings);
	var trials = array_length(timings[0]);
	
	for (var test = 0; test < tests; test++) {
		var avg = 0;
		for (var trial = 0; trial < trials; trial++) {
			global_average += timings[test][trial];
			avg += timings[test][trial];
		}
		avg /= array_length(timings[0]);
		array_push(averages, avg);		
	}
	global_average /= (tests*trials);
	
	// Compute SSR and SSE
	var ssr = 0;
	var sse = 0;
	for (var test = 0; test < tests; test++) {
		ssr += trials * power((averages[test] - global_average),2);
		
		for (var trial = 0; trial < trials; trial++) {
			sse += power(timings[test][trial] - averages[test], 2);
		}
	}
	
	// Compute degrees of freedom
	var df_ssr = tests - 1;
	var df_sse = tests * (trials - 1);
	
	// Compute F statistic
	var f_stat = ssr/sse;
	
	// Compare with critical value
	var critical_value = f_critical_value(df_ssr, df_sse);
	
	return {
		averages: averages,
		global_average: global_average,
		ssr: ssr,
		sse: sse,
		df_ssr: df_ssr,
		df_sse: df_sse,
		f_stat: f_stat,
		critical_value: critical_value,
		reject_equality: (f_stat > critical_value)		
	};
}

function f_critical_value(df_num, df_den) {
	var df_num_max = min(19, df_num); // maximum 20 tests
	var df_den_max = df_den > 120 ? infinity : df_den;
	var critical_value_idx = array_find_index(global.__F_table__, method({df_num: df_num_max, df_den: df_den_max}, function(item) {
		return item.df_num == df_num && item.df_den == df_den;
	}));
	if (critical_value_idx == -1) {
		show_debug_message("WARNING: values for df_num={0} and df_den={1} not found in F-table", df_num_max, df_den_max);
		return -1;
	}
	return global.__F_table__[critical_value_idx].value;
}

#region F table

	global.__F_table__ = [];
	function F_critical_value(df_num, df_den, value) constructor {
		self.df_num = df_num;
		self.df_den = df_den;
		self.value = value;
	}
	try {
		var fid = file_text_open_read("f_table.dat");
		while (!file_text_eof(fid))	{
			var line = string_replace_all(file_text_readln(fid), "\n", "");
			var str = string_split(line, ",");
			array_push(global.__F_table__, new F_critical_value(real(str[0]), real(str[1]), real(str[2])));
		}
		file_text_close(fid);
	}
	catch(exception) {
		throw("WARNING: Could not load F-table file");
	}

	
#endregion

#macro Benchmarks global.__benchmarks__