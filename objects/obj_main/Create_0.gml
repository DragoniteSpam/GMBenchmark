randomize();

#macro PIE_SUPERSAMPLING        1               // alynne really wanted this but it messes up a bunch of things
#macro DEFAULT_RUN_COUNT        4
#macro DEFAULT_ITERATION_COUNT  100_000

enum ESortTypes {
    BEST_TO_WORST,
    WORST_TO_BEST,
    ALPHABETICAL
}

enum EChartTypes {
    BAR,
    PIE
}

enum EDisplayTypes {
    TIME,
    PERCENT,
    OPS_PER_MS
}

self.sort_type = ESortTypes.BEST_TO_WORST;
self.chart_type = EChartTypes.BAR;
self.display_type = EDisplayTypes.TIME;

self.run_count = DEFAULT_RUN_COUNT;
self.iteration_count = DEFAULT_ITERATION_COUNT;

var ew = 360;
var eh = 32;
var chartw = 440;
var charth = 320;
var ew2 = chartw;

var c1 = 32;
var c2 = c1 + 32 + ew;

self.container = new EmuCore(0, 0, window_get_width(), window_get_height()).AddContent([
    new EmuText(c1, EMU_AUTO, ew, eh, string("[c_aqua]GameMaker Benchmark Tool[/c] ({0})", code_is_compiled() ? "YYC" : "VM")),
    new EmuList(c1, EMU_AUTO, ew, eh, "Benchmarks:", eh, 6, function() {
        var bench = self.GetSelectedItem();
        var item_list = self.GetSibling("BENCHMARK TEST LIST");
        if (item_list) {
            if (bench) {
                item_list.SetVacantText("No items in this benchmark")
                item_list.SetList(bench.tests);
            } else {
                item_list.SetVacantText("Select a benchmark")
                item_list.SetList(-1);
            }
        }
    })
        .SetAllowDeselect(false)
        .SetVacantText("No benchmark tests")
        .SetList(Benchmarks)
        .SetEntryTypes(E_ListEntryTypes.STRUCTS)
        .SetID("BENCHMARK LIST"),
    new EmuList(c1, EMU_AUTO, ew, eh, "Tests:", eh, 8, function() {
    })
        .SetVacantText("Select a benchmark")
        .SetEntryTypes(E_ListEntryTypes.STRUCTS)
        .SetID("BENCHMARK TEST LIST"),
    new EmuRadioArray(c1, EMU_AUTO, ew, eh, "Sort by:", self.sort_type, function() {
        if (obj_main.sort_type != self.value) {
            obj_main.sort_type = self.value;
            var selected_benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
            var test_list = self.GetSibling("BENCHMARK TEST LIST");
            var selected = test_list.GetSelectedItem();
            for (var i = 0, n = array_length(Benchmarks); i < n; i++) {
                switch (self.value) {
                    case ESortTypes.BEST_TO_WORST: Benchmarks[i].SortBestToWorst(); break;
                    case ESortTypes.WORST_TO_BEST: Benchmarks[i].SortWorstToBest(); break;
                    case ESortTypes.ALPHABETICAL: Benchmarks[i].SortAlphabetical(); break;
                }
            }
            
            if (selected) {
                test_list.ClearSelection();
                test_list.Select(array_get_index(selected_benchmark.tests, selected), true);
            }
        }
    })
        .SetUpdate(function() {
            var benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
            
            if (!benchmark) {
                self.SetInteractive(false);
                return;
            }
            
            if (!benchmark.runtime) {
                self.SetInteractive(false);
                return;
            }
            
            self.SetInteractive(true);
        })
        .AddOptions(["Best to Worst", "Worst to Best", "Alphabetical"]),
	new EmuButton(c1, EMU_AUTO, ew, eh, "Export CSV...", function() {
		obj_main.ExportCSV();
	}),
    new EmuRadioArray(c2, 32, ew2, eh, "Chart:", self.chart_type, function() {
        obj_main.chart_type = self.value;
        switch (self.value) {
            case EChartTypes.PIE:
                self.GetSibling("CHART").SetScale(PIE_SUPERSAMPLING);
                self.GetSibling("DISPLAY").SetEnabled(false);
                break;
            case EChartTypes.BAR:
                self.GetSibling("CHART").SetScale(1);
                self.GetSibling("DISPLAY")
                    .SetEnabled(true)
                    .callback();
                break;
        }
    })
        .SetColumns(1, chartw / 3)
        .AddOptions(["Bar", "Pie"]),
    new EmuRadioArray(c2, EMU_AUTO, ew2, eh, "Data display:", self.display_type, function() {
        obj_main.display_type = self.value;
        switch (self.value) {
            case EDisplayTypes.TIME:
                //self.GetSibling("READOUT").SetText("Lower is better");
                break;
            case EDisplayTypes.PERCENT:
                //self.GetSibling("READOUT").SetText("Higher is better");
                break;
            case EDisplayTypes.OPS_PER_MS:
                //self.GetSibling("READOUT").SetText("Higher is better");
                break;
        }
    })
        .SetID("DISPLAY")
        .SetColumns(1, chartw / 3)
        .AddOptions(["Time", "Percent", "Ops/ms"]),
    new EmuRenderSurface(c2, EMU_AUTO, chartw, charth, function(mx, my) {
        // render
        draw_clear_alpha(c_black, 0);
        switch (obj_main.chart_type) {
            case EChartTypes.PIE:
                obj_main.DrawPieChart(self.width * self.scale, self.height * self.scale, min(self.width, self.height) / 2 * self.scale * 0.9, mx * self.scale, my * self.scale);
                break;
            case EChartTypes.BAR:
                obj_main.DrawBarChart(self.width * self.scale, self.height * self.scale, mx * self.scale, my * self.scale);
                break;
        }
    }, function(mx, my) {
        // step
    })
        .SetID("CHART")
        .SetScale(1),
    new EmuInput(c2, EMU_AUTO, ew2 / 2, eh, "Trials: ", DEFAULT_RUN_COUNT, "Number of independant runs", 4, E_InputTypes.INT, function() {
        obj_main.run_count = int64(self.value);
    })
        .SetRealNumberBounds(1, 100)
        .SetUpdate(function() {
        }),
    new EmuInput(c2 + ew2 / 2, EMU_INLINE, ew2 / 2, eh, "Iterations: ", DEFAULT_ITERATION_COUNT, "Iterations per run", 9, E_InputTypes.INT, function() {
        obj_main.iteration_count = int64(self.value);
    })
        .SetRealNumberBounds(10, 10_000_000_000)
        .SetID("ITERATIONS")
        .SetUpdate(function() {
        }),
    new EmuButton(c2, EMU_AUTO, ew2 / 2 - 4, eh, "Suggest Iterations", function() {
        var benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
        
        var t_start = get_timer();
        benchmark.Run(1, 100, false);
        var short_trial_ms = max(0.001, (get_timer() - t_start) / 1000);
        
        static ideal_runtime = 1000;                    // ms
        var trial_iterations_per_ms = 10 / short_trial_ms;
        var trial_iterations_per_runtime = trial_iterations_per_ms * ideal_runtime;
        
        obj_main.iteration_count = benchmark_log_ceil(trial_iterations_per_runtime);
        self.GetSibling("ITERATIONS").SetValue(obj_main.iteration_count);
    })
        .SetUpdate(function() {
            var benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
            self.SetInteractive(!!benchmark);
        }),
    new EmuButton(c2 + ew2 / 2 + 4, EMU_INLINE, ew2 / 2, eh, "Run Benchmark", function() {
            var benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
            benchmark.Run(obj_main.run_count, obj_main.iteration_count);
    })
        .SetUpdate(function() {
            var benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
            self.SetInteractive(!!benchmark);
        }),
    new EmuText(c2, EMU_AUTO, ew2, eh * 2.5, "")
        .SetUpdate(function() {
            var benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
            
            // early exit: no benchmark selected
            if (!benchmark) {
                self.text = "";
                return;
            }
            
            // early exit: benchmark selected but not run
            if (!benchmark.runtime) {
                self.text = string(@"[c_aqua]{0}[/c]
Tests contained: {1}
Not run yet!
", benchmark.source_name, array_length(benchmark.tests));
                return;
            }
            
            self.text = string(@"[c_aqua]{0}[/c]
Tests contained: {1}
{2} ms ({3} trials of {4} iterations)
", benchmark.source_name, array_length(benchmark.tests), benchmark.runtime.ms * benchmark.runtime.trials, benchmark.runtime.trials, benchmark.runtime.iterations);
        }),
    new EmuText(c2, EMU_AUTO, ew2, eh * 3, "")
        .SetUpdate(function() {
            var benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
            var test = self.GetSibling("BENCHMARK TEST LIST").GetSelectedItem();
            
            // early exit: no appropriate test selected
            if (!benchmark || !benchmark.runtime || !test) {
                self.text = "";
                return;
            }
            
            // general case: benchmark selected and run, test selected
            var test_index = array_get_index(benchmark.tests, test);
            self.text = string(@"[c_aqua]{0}[/c] ([#{1}]#{1}[/c])
{2} ms ({3}% relative performance)
Expect to afford {4} per ms
", test.source_name, colour_to_hex(test.color), test.runtime.ms, test.runtime.percentage * 100, benchmark_format(test.runtime.per_ms));
        })
]);

self.DrawBarChart = function(w, h, mx, my) {
    draw_rectangle_colour(1, 1, w - 2, h - 2, c_white, c_white, c_white, c_white, true);
    
    var bench_list = self.container.GetChild("BENCHMARK LIST");
    var current_benchmark = bench_list.GetSelectedItem();
    if (!current_benchmark) {
        scribble("Select a benchmark to see the results")
            .align(fa_center, fa_middle)
            .draw(w div 2, h div 2);
        return;
    }
    
    if (!current_benchmark.runtime) {
        scribble("Benchmark not yet run")
            .align(fa_center, fa_middle)
            .draw(w div 2, h div 2);
        return;
    }
    
    var test_list = self.container.GetChild("BENCHMARK TEST LIST");
    var selected_benchmark_test = test_list.GetSelectedItem();
    var test_count = array_length(current_benchmark.tests);
    
    static bar_default_spacing = 16;        // pixels
    static bar_min_width = 12;
    
    var best_trial = array_reduce(current_benchmark.tests, function(winner, item) {
        if (winner == undefined) return item;
        if (item.runtime.ms < winner.runtime.ms) return item;
        return winner;
    }, undefined);
    var worst_trial = array_reduce(current_benchmark.tests, function(winner, item) {
        if (winner == undefined) return item;
        if (item.runtime.ms < winner.runtime.ms) return winner;
        return item;
    }, undefined);
    
    var max_value = 0;
    var max_value_log = 1;          // feather shut up
    switch (obj_main.display_type) {
        case EDisplayTypes.TIME:
            max_value = benchmark_log_ceil(worst_trial.runtime.ms);
            break;
        case EDisplayTypes.PERCENT:
            // not relevant
            break;
        case EDisplayTypes.OPS_PER_MS:
            max_value = benchmark_log_ceil(best_trial.runtime.per_ms);
            break;
    }
    var mclick = mouse_check_button_pressed(mb_left);
    
    var bar_spacing = bar_default_spacing;
    var bar_start_x = 16;
    var bar_finish_x = w - 96;
    var bar_start_y = 32;
    var bar_finish_y = h - 16;
    
    var bar_line_spacing_main = 16;
    var bar_line_spacing_sub = 8;
    
    var bar_width = max(bar_min_width, (bar_finish_x - bar_start_x - test_count * bar_spacing) / test_count);
    
    for (var i = 0; i < test_count; i++) {
        var test = current_benchmark.tests[i];
        
        if (test == selected_benchmark_test) {
            shader_set(shd_dither);
        }
        
        var x1 = bar_start_x + (bar_width + bar_spacing) * i;
        var y1 = 0;
        var x2 =  x1 + bar_width;
        var y2 = bar_finish_y;
        
        switch (obj_main.display_type) {
            case EDisplayTypes.TIME:
                y1 = y2 - (bar_finish_y - bar_start_y) * test.runtime.ms / max_value;
                break;
            case EDisplayTypes.PERCENT:
                y1 = y2 - (bar_finish_y - bar_start_y) * test.runtime.percentage;
                break;
            case EDisplayTypes.OPS_PER_MS:
                y1 = y2 - (bar_finish_y - bar_start_y) * test.runtime.per_ms / max_value;
                break;
        }
        
        draw_rectangle_colour(x1, y1,x2, y2, test.color, test.color, test.color, test.color, false);
        
        if (point_in_rectangle(mx, my, x1, y1, x2, y2)) {
            if (mclick) {
                test_list.ClearSelection();
                test_list.Select(i, true);
            }
        }
        
        if (test == selected_benchmark_test) {
            shader_reset();
        }
        
        if (test == best_trial) {
            var quack_highest_limit = bar_start_y + 32;
            draw_sprite(spr_quack, 0, mean(x1, x2), max(y1 - sprite_get_height(spr_quack) / 2, quack_highest_limit));
        }
    }
    
    if (selected_benchmark_test != undefined) {
        var x1 = bar_start_x + (bar_width + bar_spacing) * i;
        var y1 = 0;
        var x2 =  x1 + bar_width;
        var y2 = bar_finish_y;
        
        var y_plus_five = 0;
        var y_minus_five = 0;
        
        switch (obj_main.display_type) {
            case EDisplayTypes.TIME:
                y1              = y2 - (bar_finish_y - bar_start_y) * selected_benchmark_test.runtime.ms / max_value;
                y_plus_five     = y2 - (bar_finish_y - bar_start_y) * (selected_benchmark_test.runtime.ms * 1.1) / max_value;
                y_minus_five    = y2 - (bar_finish_y - bar_start_y) * (selected_benchmark_test.runtime.ms * 0.9) / max_value;
                break;
            case EDisplayTypes.PERCENT:
                y1              = y2 - (bar_finish_y - bar_start_y) * selected_benchmark_test.runtime.percentage;
                y_plus_five     = y2 - (bar_finish_y - bar_start_y) * (selected_benchmark_test.runtime.percentage * 1.1);
                y_minus_five    = y2 - (bar_finish_y - bar_start_y) * (selected_benchmark_test.runtime.percentage * 0.9);
                break;
            case EDisplayTypes.OPS_PER_MS:
                y1              = y2 - (bar_finish_y - bar_start_y) * selected_benchmark_test.runtime.per_ms / max_value;
                y_plus_five     = y2 - (bar_finish_y - bar_start_y) * (selected_benchmark_test.runtime.per_ms * 1.1) / max_value;
                y_minus_five    = y2 - (bar_finish_y - bar_start_y) * (selected_benchmark_test.runtime.per_ms * 0.9) / max_value;
                break;
        }
        
        static thickness = 2;
        static interval = 14;
        
        for (var i = 0; i < bar_finish_x; i += interval * 2) {
            draw_line_width_colour(
                i,
                y_plus_five,
                min(i + interval, bar_finish_x),
                y_plus_five,
                thickness,
                c_red, c_red
            );
            draw_line_width_colour(
                min(i + interval, bar_finish_x),
                y_minus_five,
                min(i + interval * 2, bar_finish_x),
                y_minus_five,
                thickness,
                c_red, c_red
            );
        }
    }
    
    draw_line_colour(bar_finish_x, 0, bar_finish_x, bar_finish_y, c_white, c_white);
    draw_line_colour(0, bar_finish_y, bar_finish_x, bar_finish_y, c_white, c_white);
    
    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    var label_spacing = (bar_finish_y - bar_start_y) div 4;
    var label_4 = bar_finish_y - label_spacing * 4;
    var label_3 = bar_finish_y - label_spacing * 3;
    var label_2 = bar_finish_y - label_spacing * 2;
    var label_1 = bar_finish_y - label_spacing * 1;
    
    var label_4_text = "---";
    var label_3_text = "---";
    var label_2_text = "---";
    var label_1_text = "---";
    
    switch (obj_main.display_type) {
        case EDisplayTypes.TIME:
            if (max_value >= 4) {
                label_4_text = string("{0} ms", max_value);
                label_3_text = string("{0} ms", (max_value div 4) * 3);
                label_2_text = string("{0} ms", (max_value div 4) * 2);
                label_1_text = string("{0} ms", (max_value div 4));
            } else {
                max_value = ((max_value * 1000) div 10) * 10;
                label_4_text = string("{0} us", max_value);
                label_3_text = string("{0} us", (max_value div 4) * 3);
                label_2_text = string("{0} us", (max_value div 4) * 2);
                label_1_text = string("{0} us", (max_value div 4));
            }
            break;
        case EDisplayTypes.PERCENT:
            label_4_text = "100%";
            label_3_text = "75%";
            label_2_text = "50%";
            label_1_text = "25%";
            break;
        case EDisplayTypes.OPS_PER_MS:
            if (max_value >= 4) {
                label_4_text = string("{0}/ms", benchmark_format(max_value));
                label_3_text = string("{0}/ms", benchmark_format((max_value div 4) * 3));
                label_2_text = string("{0}/ms", benchmark_format((max_value div 4) * 2));
                label_1_text = string("{0}/ms", benchmark_format((max_value div 4)));
            } else {
                label_4_text = string("{0}/ms", benchmark_format(max_value));
                label_3_text = string("{0}/ms", benchmark_format((max_value / 4) * 3));
                label_2_text = string("{0}/ms", benchmark_format((max_value / 4) * 2));
                label_1_text = string("{0}/ms", benchmark_format((max_value / 4)));
            }
            break;
    }
    
    draw_text(bar_finish_x + 16, label_4, label_4_text);
    draw_text(bar_finish_x + 16, label_3, label_3_text);
    draw_text(bar_finish_x + 16, label_2, label_2_text);
    draw_text(bar_finish_x + 16, label_1, label_1_text);
    
    draw_set_alpha(0.9);
    
    for (var i = 0; i < bar_finish_x; i += bar_line_spacing_main * 2) {
        draw_line_colour(i, label_4, i + bar_line_spacing_main, label_4, c_white, c_white);
        draw_line_colour(i, label_2, i + bar_line_spacing_main, label_2, c_white, c_white);
    }
    
    draw_set_alpha(0.75);
    
    for (var i = 0; i < bar_finish_x; i += bar_line_spacing_sub * 2) {
        draw_line_colour(i, label_3, i + bar_line_spacing_sub, label_3, c_white, c_white);
        draw_line_colour(i, label_1, i + bar_line_spacing_sub, label_1, c_white, c_white);
    }
    
    draw_set_alpha(1);
};

self.DrawPieChart = function(w, h, r, mx, my) {
    draw_rectangle_colour(1, 1, w - 2, h - 2, c_white, c_white, c_white, c_white, true);
    
    // draw the pie chart centered in the middle of the canvas
    var xx = w div 2;
    var yy = h div 2;
    
    var bench_list = self.container.GetChild("BENCHMARK LIST");
    var current_benchmark = bench_list.GetSelectedItem();
    if (!current_benchmark) {
        scribble("Select a benchmark to see the results")
            .align(fa_center, fa_middle)
            .draw(xx, yy);
        return;
    }
    
    if (!current_benchmark.runtime) {
        scribble("Benchmark not yet run")
            .align(fa_center, fa_middle)
            .draw(xx, yy);
        return;
    }
    
    var test_list = self.container.GetChild("BENCHMARK TEST LIST");
    var selected_benchmark_test = test_list.GetSelectedItem();
    var benchmark_count = array_length(current_benchmark.tests);
    
    static resolution = 2;          // degrees
    
    var mdist = point_distance(xx, yy, mx, my);
    var mdir = point_direction(xx, yy, mx, my);
    var mclick = mouse_check_button_pressed(mb_left);
    
    var angle = 0;
    for (var i = 0; i < benchmark_count; i++) {
        var test = current_benchmark.tests[i];
        var slice_start = angle;
        var slice_end = 360 * test.runtime.ms / current_benchmark.runtime.ms + angle;
        
        if (mdist < r) {
            if (mdir >= slice_start && mdir < slice_end) {
                if (mclick) {
                    test_list.ClearSelection();
                    test_list.Select(i, true);
                }
            }
        }
        
        if (test == selected_benchmark_test) {
            shader_set(shd_dither);
        }
        
        draw_primitive_begin(pr_trianglefan);
        draw_vertex_colour(xx, yy, test.color, 1);
        draw_vertex_colour(xx + r * dcos(angle), yy - r * dsin(angle), test.color, 1);
        while (angle <= slice_end) {
            angle += resolution;
            draw_vertex_colour(xx + r * dcos(angle), yy - r * dsin(angle), test.color, 1);
        }
        draw_primitive_end();
        
        if (test == selected_benchmark_test) {
            shader_reset();
        }
    }
};

self.ExportCSV = function() {
	var filename = get_save_filename("CSV files|*.csv", "results.csv");
	if (filename == "") return;
	
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
};