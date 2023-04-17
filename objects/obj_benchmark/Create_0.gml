self.benchmarks = [];
self.color_offset = random(255);

self.DrawPieChart = function(r, colors = undefined) {
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
        draw_vertex_colour(self.x, self.y, colors[i], 1);
        draw_vertex_colour(self.x + r * dcos(angle), self.y - r * dsin(angle), colors[i], 1);
        while (angle <= slice_end) {
            angle += resolution;
            draw_vertex_colour(self.x + r * dcos(angle), self.y - r * dsin(angle), colors[i], 1);
        }
        draw_primitive_end();
    }
};