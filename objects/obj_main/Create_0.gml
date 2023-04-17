randomize();

var ew = 320;
var eh = 32;

self.container = new EmuCore(0, 0, window_get_width(), window_get_height()).AddContent([
    new EmuList(32, EMU_AUTO, ew, eh, "Benchmarks:", eh, 12, function() {
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
    new EmuList(32, EMU_AUTO, ew, eh, "Results:", eh, 8, function() {
    })
        .SetVacantText("Select a benchmark")
        .SetEntryTypes(E_ListEntryTypes.STRUCTS)
        .SetID("BENCHMARK TEST LIST")
]);

self.DrawPieChart = function(x, y, r, colors = undefined) {
    var current_benchmark = self.container.GetChild("BENCHMARK LIST").GetSelectedItem();
    if (!current_benchmark) return;
    
    var selected_benchmark_test = self.container.GetChild("BENCHMARK TEST LIST").GetSelectedItem();
    
    static color_offset = random(255);
    var benchmark_count = array_length(current_benchmark.tests);
    if (colors == undefined) {
        colors = array_create(benchmark_count);
        for (var i = 0; i < benchmark_count; i++) {
            colors[i] = make_colour_hsv((color_offset + i / benchmark_count * 255) % 255, 255, 255);
        }
    }
    
    var total_time = 0;
    for (i = 0; i < benchmark_count; i++) {
        total_time += current_benchmark.tests[i].runtime;
    }
    
    static resolution = 4;          // degrees
    
    var angle = 0;
    for (var i = 0; i < benchmark_count; i++) {
        var test = current_benchmark.tests[i];
        var slice_start = angle;
        var slice_end = 360 * test.runtime / total_time + angle;
        
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