// initialize the for loop over the array down here so it doesn't take up time in the tests
global.__test_array = array_create(1_000_000);

Benchmarks = [
    // growable collections
    new Benchmark("Growable Collections x 100,000", new TestCase("array_push", function() {
        var array = [];
        repeat (100_000) {
            array_push(array, 0);
        }
    }), new TestCase("ds_list_add", function() {
        var list = ds_list_create();
        repeat (100_000) {
            ds_list_add(list, 0);
        }
        ds_list_destroy(list);
    }), new TestCase("buffer_grow", function() {
        var buffer = buffer_create(1, buffer_grow, 1);
        repeat (100_000) {
            buffer_write(buffer, buffer_u32, 0);
        }
        buffer_delete(buffer)
    })),
    
    // loop iterations
    new Benchmark("Fast Loops x 1,000,000", new TestCase("for over array size", function() {
        for (var i = 0; i < array_length(global.__test_array); i++) {
            var val = global.__test_array[i];
        }
    }),
    new TestCase("for over cached array size", function() {
        for (var i = 0, n = array_length(global.__test_array); i < n; i++) {
            var val = global.__test_array[i];
        }
    }), new TestCase("repeat over array", function() {
        var i = 0;
        repeat (array_length(global.__test_array)) {
            var val = global.__test_array[i];
            i++;
        }
    }), new TestCase("while over array", function() {
        var i = 0;
        while (i < array_length(global.__test_array)) {
            var val = global.__test_array[i];
            i++;
        }
    }), new TestCase("while over cached array size", function() {
        var i = 0;
        var n = array_length(global.__test_array);
        while (i < n) {
            var val = global.__test_array[i];
            i++;
        }
    })),
    
    // variable access
    new Benchmark("Variable access x 1,000,000", new TestCase("dot operator", function() {
        var struct = { x: 0 };
        repeat (1_000_000) {
            var val = struct.x;
        }
    }),
    new TestCase("struct accessor", function() {
        var struct = { x: 0 };
        repeat (1_000_000) {
            var val = struct[$ "x"];
        }
    }), new TestCase("variable hash", function() {
        var struct = { x: 0 };
        var hash = variable_get_hash("x");
        repeat (1_000_000) {
            var val = struct_get_from_hash(struct, hash);
        }
    }))
];
