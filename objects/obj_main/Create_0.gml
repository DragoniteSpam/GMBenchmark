randomize();

enum ESortTypes {
    BEST_TO_WORST,
    WORST_TO_BEST,
    ALPHABETICAL
}

self.sort_type = ESortTypes.BEST_TO_WORST;

var ew = 360;
var eh = 32;

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
    new EmuList(c1, EMU_AUTO, ew, eh, "Results:", eh, 8, function() {
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
        .AddOptions(["Best to Worst", "Worst to Best", "Alphabetical"]),
    new EmuRenderSurface(c2, 32, 360, 360, function(mx, my) {
        // render
        draw_clear_alpha(c_black, 0);
        obj_main.DrawPieChart(self.width * self.scale, self.height * self.scale, min(self.width, self.height) / 2 * self.scale, mx * self.scale, my * self.scale);
    }, function(mx, my) {
        // step
    })
        .SetScale(4),
    new EmuText(c2, EMU_AUTO, ew, ew, "")
        .SetUpdate(function() {
            var benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
            var test = self.GetSibling("BENCHMARK TEST LIST").GetSelectedItem();
            
            if (test) {
                var test_index = array_get_index(benchmark.tests, test);
                self.text = string(@"[c_aqua]{0}[/c]
Total runtime: {1} ms

[c_aqua]{2}[/c] ([#{3}]#{3}[/c])
Test {4} of {5}
Test runtime: {6} ms ({7}% of total)
", benchmark.source_name, benchmark.runtime, test.source_name, colour_to_hex(test.color), test_index, array_length(benchmark.tests), test.runtime, test.runtime / benchmark.runtime * 100);
            } else if (benchmark) {
                self.text = string(@"[c_aqua]{0}[/c]
Total runtime: {1} ms
Tests contained: {2}
", benchmark.source_name, benchmark.runtime, array_length(benchmark.tests));
            } else {
                self.text = "";
            }
        })
]);

self.DrawPieChart = function(w, h, r, mx, my) {
    // draw the pie chart centered in the middle of the canvas
    var xx = w div 2;
    var yy = h div 2;
    
    var test_list = obj_main.container.GetChild("BENCHMARK TEST LIST");
    var current_benchmark = test_list.GetSelectedItem();
    if (!current_benchmark) return;
    
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
        var slice_end = 360 * test.runtime / current_benchmark.runtime + angle;
        
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