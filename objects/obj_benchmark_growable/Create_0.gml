event_inherited();

self.benchmarks = benchmark(new TestCase("10,000 x array_push", function() {
    var array = [];
    repeat (10_000) {
        array_push(array, 0);
    }
}), new TestCase("10,000 x ds_list_add", function() {
    var list = ds_list_create();
    repeat (10_000) {
        ds_list_add(list, 0);
    }
}));