Benchmarks = [
    new Benchmark("Growable Collections x 10,000", new TestCase("array_push", function() {
        var array = [];
        repeat (10_000) {
            array_push(array, 0);
        }
    }), new TestCase("ds_list_add", function() {
        var list = ds_list_create();
        repeat (10_000) {
            ds_list_add(list, 0);
        }
        ds_list_destroy(list);
    }))
];