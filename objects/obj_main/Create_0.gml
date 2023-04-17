randomize();

var ew = 360;
var eh = 32;

var c1 = 32;
var c2 = c1 + 32 + ew;

self.container = new EmuCore(0, 0, window_get_width(), window_get_height()).AddContent([
    new EmuText(c1, EMU_AUTO, ew, eh, string("[c_aqua]GameMaker Benchmark Tool[/c]({0})", code_is_compiled() ? "YYC" : "VM")),
    new EmuList(c1, EMU_AUTO, ew, eh, "Benchmarks:", eh, 10, function() {
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
    new EmuRenderSurface(c2, 32, 360, 360, function(mx, my) {
        // render
        draw_clear_alpha(c_black, 0);
        obj_main.DrawPieChart(self.width / 2, self.height / 2, min(self.width, self.height) / 2);
    }, function(mx, my) {
        // step
    }),
    new EmuText(c2, EMU_AUTO, ew, ew, "")
        .SetUpdate(function() {
            var benchmark = self.GetSibling("BENCHMARK LIST").GetSelectedItem();
            var test = self.GetSibling("BENCHMARK TEST LIST").GetSelectedItem();
            
            if (test) {
                var test_index = array_get_index(benchmark.tests, test);
                self.text = string(@"[c_aqua]{0}[/c]
Total runtime: {1}

[c_aqua]{2}[/c]
Test {3} of {4}
Test runtime: {5} ({6}% of total)
", benchmark.source_name, benchmark.runtime, test.source_name, test_index, array_length(benchmark.tests), test.runtime, test.runtime / benchmark.runtime * 100);
            } else if (benchmark) {
                self.text = string(@"[c_aqua]{0}[/c]
Total runtime: {1}
Tests contained: {2}
", benchmark.source_name, benchmark.runtime, array_length(benchmark.tests));
            } else {
                self.text = "";
            }
        })
]);

self.DrawPieChart = function(x, y, r) {
    var current_benchmark = self.container.GetChild("BENCHMARK LIST").GetSelectedItem();
    if (!current_benchmark) return;
    
    var selected_benchmark_test = self.container.GetChild("BENCHMARK TEST LIST").GetSelectedItem();
    
    static color_offset = random(255);
    var benchmark_count = array_length(current_benchmark.tests);
    var colors = array_create(benchmark_count);
    for (var i = 0; i < benchmark_count; i++) {
        colors[i] = make_colour_hsv((color_offset + i / benchmark_count * 255) % 255, 255, 255);
    }
    
    static resolution = 2;          // degrees
    
    var angle = 0;
    for (var i = 0; i < benchmark_count; i++) {
        var test = current_benchmark.tests[i];
        var slice_start = angle;
        var slice_end = 360 * test.runtime / current_benchmark.runtime + angle;
        
        if (test == selected_benchmark_test) {
            shader_set(shd_selected_benchmark_test);
        }
        
        draw_primitive_begin(pr_trianglefan);
        draw_vertex_colour(x, y, colors[i], 1);
        draw_vertex_colour(x + r * dcos(angle), y - r * dsin(angle), colors[i], 1);
        while (angle <= slice_end) {
            angle += resolution;
            draw_vertex_colour(x + r * dcos(angle), y - r * dsin(angle), colors[i], 1);
        }
        draw_primitive_end();
        
        if (test == selected_benchmark_test) {
            shader_reset();
        }
    }
};