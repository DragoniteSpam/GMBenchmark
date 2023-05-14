// initialize the for loop over the array down here so it doesn't take up time in the tests
global.__test_array = array_create(1_000_000);

var n = 1_000;
global.array_1k = array_create(n);
for (var i = 0; i < n; i++) {
    global.array_1k[i] = random(1000);
}

n = 100;
global.array_100 = array_create(n);
for (var i = 0; i < n; i++) {
    global.array_100[i] = random(1000);
}

n = 10_000;
global.array_10k = array_create(n);
for (var i = 0; i < n; i++) {
    global.array_10k[i] = random(1000);
}

n = 100_000;
global.array_100k = array_create(n);
for (var i = 0; i < n; i++) {
    global.array_100k[i] = random(1000);
}

n = 1_000_000;
global.array_1m = array_create(n);
for (var i = 0; i < n; i++) {
    global.array_1m[i] = random(1000);
}

n = 10_000_000;
global.array_10m = array_create(n);
for (var i = 0; i < n; i++) {
    global.array_10m[i] = random(1000);
}

Benchmarks = [
    // growable collections
    new Benchmark("Growable Collections", [
        new TestCase("array_push", function(iterations) {
            var array = [];
            repeat (iterations) {
                array_push(array, 0);
            }
        }), new TestCase("ds_list_add", function(iterations) {
            var list = ds_list_create();
            repeat (iterations) {
                ds_list_add(list, 0);
            }
            ds_list_destroy(list);
        }), new TestCase("buffer_grow", function(iterations) {
            var buffer = buffer_create(1, buffer_grow, 1);
            repeat (iterations) {
                buffer_write(buffer, buffer_u32, 0);
            }
            buffer_delete(buffer)
        })
    ]),
    
    // loop iterations
    new Benchmark("Fast Loops", [
        new TestCase("for over array size", function(iterations) {
            for (var i = 0; i < array_length(global.__test_array); i++) {
                var val = global.__test_array[i];
            }
        }),
        new TestCase("for over cached array size", function(iterations) {
            for (var i = 0, n = array_length(global.__test_array); i < n; i++) {
                var val = global.__test_array[i];
            }
        }), new TestCase("repeat over array", function(iterations) {
            var i = 0;
            repeat (array_length(global.__test_array)) {
                var val = global.__test_array[i];
                i++;
            }
        }), new TestCase("while over array", function(iterations) {
            var i = 0;
            while (i < array_length(global.__test_array)) {
                var val = global.__test_array[i];
                i++;
            }
        }), new TestCase("while over cached array size", function(iterations) {
            var i = 0;
            var n = array_length(global.__test_array);
            while (i < n) {
                var val = global.__test_array[i];
                i++;
            }
        })
    ]),
    // variable access
    new Benchmark("Variable access", [
        new TestCase("dot operator", function(iterations) {
            var struct = { x: 0 };
            repeat (iterations) {
                var val = struct.x;
            }
        }),
        new TestCase("struct accessor", function(iterations) {
            var struct = { x: 0 };
            repeat (iterations) {
                var val = struct[$ "x"];
            }
        }), new TestCase("variable hash", function(iterations) {
            var struct = { x: 0 };
            var hash = variable_get_hash("x");
            repeat (iterations) {
                var val = struct_get_from_hash(struct, hash);
            }
        })
    ]),
    
    // recycling matrices
    new Benchmark("Identity matrix", [
        new TestCase("like a normal person", function(iterations) {
            repeat (iterations) {
                matrix_set(matrix_world, matrix_build_identity());
            }
        }),
        new TestCase("caching it globally", function(iterations) {
            global.identity = matrix_build_identity();
            repeat (iterations) {
                matrix_set(matrix_world, global.identity);
            }
        })
    ]),
    
    // array FP
    new Benchmark("Array iteration", [
        new TestCase("for loop, the not stupid way", function(iterations) {
            var t = 0;
            for (var i = 0, n = array_length(global.__test_array); i < n; i++) {
                t += global.__test_array[i];
            }
        }),
        new TestCase("for loop, the stupid way", function(iterations) {
            var t = 0;
            for (var i = 0; i < array_length(global.__test_array); i++) {
                t += global.__test_array[i];
            }
        }),
        new TestCase("repeat loop", function(iterations) {
            var t = 0;
            var i = 0;
            repeat (array_length(global.__test_array)) {
                t += global.__test_array[i];
                i++;
            }
        }),
        new TestCase("array_reduce", function(iterations) {
            var t = array_reduce(global.__test_array, function(previous, current) {
                return previous + current;
            });
        })
    ]),
    
    // matrix math
    new Benchmark("Matrix by vector", [
        new TestCase("matrix_transform_vertex", function(iterations) {
            var matrix = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
            var xx = 1;
            var yy = 2;
            var zz = 3;
            var ww = 4;
            repeat (iterations) {
                var value = matrix_transform_vertex(matrix, xx, yy, zz, ww);
            }
        }),
        new TestCase("doing it yourself", function(iterations) {
            var matrix = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
            var xx = 1;
            var yy = 2;
            var zz = 3;
            var ww = 4;
            repeat (iterations) {
                var value = [
                    matrix[0] * xx + matrix[4] * yy + matrix[8] * zz + matrix[12] * ww,
                    matrix[1] * xx + matrix[5] * yy + matrix[9] * zz + matrix[13] * ww,
                    matrix[2] * xx + matrix[6] * yy + matrix[10] * zz + matrix[14] * ww,
                    matrix[3] * xx + matrix[7] * yy + matrix[11] * zz + matrix[15] * ww
                ];
            }
        })
    ]),
    
    // string splitting
    new Benchmark("String splitting (moderate strings)", [
        new TestCase("built-in split function", function(iterations) {
            var str = "The quick brown fox jumped over the lazy dog";
            repeat (iterations) {
                var results = string_split(str, " ");
            }
        }),
        new TestCase("doing it yourself", function(iterations) {
            var str = "The quick brown fox jumped over the lazy dog";
            repeat (iterations) {
                var results = split(str, " ");
            }
        })
    ]),
    
    // array sorting scaling
    new Benchmark("Scaling Array Sort", [
        new TestCase("100 elements", function(iterations) {
            array_sort(global.array_100, true);
        }),
        new TestCase("1,000 elements", function(iterations) {
            array_sort(global.array_1k, true);
        }),
        new TestCase("10,000 elements", function(iterations) {
            array_sort(global.array_10k, true);
        }),
        new TestCase("100,000 elements", function(iterations) {
            array_sort(global.array_100k, true);
        }),
        new TestCase("1,000,000 elements", function(iterations) {
            array_sort(global.array_1m, true);
        }),
        new TestCase("10,000,000 elements", function(iterations) {
            array_sort(global.array_10m, true);
        })
    ])
];