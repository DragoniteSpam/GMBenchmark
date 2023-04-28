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
    })),
    
    // recycling matrices
    new Benchmark("Identity matrix x 1,000,000", new TestCase("like a normal person", function() {
        repeat (1_000_000) {
            matrix_set(matrix_world, matrix_build_identity());
        }
    }),
    new TestCase("caching it globally", function() {
        global.identity = matrix_build_identity();
        repeat (1_000_000) {
            matrix_set(matrix_world, global.identity);
        }
    })),
    
    // array FP
    new Benchmark("Array iteration x 1,000,000", new TestCase("for loop, the not stupid way", function() {
        var t = 0;
        for (var i = 0, n = array_length(global.__test_array); i < n; i++) {
            t += global.__test_array[i];
        }
    }),
    new TestCase("for loop, the stupid way", function() {
        var t = 0;
        for (var i = 0; i < array_length(global.__test_array); i++) {
            t += global.__test_array[i];
        }
    }),
    new TestCase("repeat loop", function() {
        var t = 0;
        var i = 0;
        repeat (array_length(global.__test_array)) {
            t += global.__test_array[i];
            i++;
        }
    }),
    new TestCase("array_reduce", function() {
        var t = array_reduce(global.__test_array, function(previous, current) {
            return previous + current;
        });
    })),
    
    // matrix math
    new Benchmark("Matrix by vector x 10,000", new TestCase("matrix_transform_vertex", function() {
        var matrix = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
        var xx = 1;
        var yy = 2;
        var zz = 3;
        var ww = 4;
        repeat (100_000) {
            var value = matrix_transform_vertex(matrix, xx, yy, zz, ww);
        }
    }),
    new TestCase("doing it yourself", function() {
        var matrix = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
        var xx = 1;
        var yy = 2;
        var zz = 3;
        var ww = 4;
        repeat (100_000) {
            var value = [
                matrix[0] * xx + matrix[4] * yy + matrix[8] * zz + matrix[12] * ww,
                matrix[1] * xx + matrix[5] * yy + matrix[9] * zz + matrix[13] * ww,
                matrix[2] * xx + matrix[6] * yy + matrix[10] * zz + matrix[14] * ww,
                matrix[3] * xx + matrix[7] * yy + matrix[11] * zz + matrix[15] * ww
            ];
        }
    })),
    
    // string splitting
    new Benchmark("String splitting x 10,000 (moderate)", new TestCase("built-in split function", function() {
        var str = "The quick brown fox jumped over the lazy dog";
        repeat (10_000) {
            var results = string_split(str, " ");
        }
    }),
    new TestCase("doing it yourself", function() {
        var str = "The quick brown fox jumped over the lazy dog";
        repeat (10_000) {
            var results = split(str, " ");
        }
    })),
];