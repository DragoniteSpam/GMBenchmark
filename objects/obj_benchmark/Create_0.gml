self.benchmarks = [];
self.color_offset = random(255);

self.DrawPieChart = function(x, y, r, colors = undefined) {
    var benchmark_count = array_length(self.benchmarks);
    if (colors == undefined) {
        colors = array_create(benchmark_count);
        for (var i = 0; i < benchmark_count; i++) {
            colors[i] = make_colour_hsv((self.color_offset + i / benchmark_count * 255) % 255, 255, 255);
        }
    }
    
    var total_time = 0;
    for (i = 0; i < benchmark_count; i++) {
        total_time += self.benchmarks[i].runtime;
    }
    
    static resolution = 4;          // degrees
    
    var angle = 0;
    for (var i = 0; i < benchmark_count; i++) {
        var slice_start = angle;
        var slice_end = 360 * self.benchmarks[i].runtime / total_time + angle;
        draw_primitive_begin(pr_trianglefan);
        draw_vertex_colour(x, y, colors[i], 1);
        draw_vertex_colour(x + r * dcos(angle), y - r * dsin(angle), colors[i], 1);
        while (angle <= slice_end) {
            angle += resolution;
            draw_vertex_colour(x + r * dcos(angle), y - r * dsin(angle), colors[i], 1);
        }
        draw_primitive_end();
    }
};

self.DrawTextList = function(x, y) {
    static spacing = 20;
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    draw_set_colour(c_white);
    
    for (var i = 0, n = array_length(self.benchmarks); i < n; i++) {
        var test = self.benchmarks[i];
        draw_text(x, y + spacing * i, string("{0}: {1} ms", test.name, test.runtime));
    }
};