Benchmarks = [
    #region growable collections
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
    #endregion
    
    #region dot products
    new Benchmark("Dot Products", [
        new TestCase("2D, manually", function(iterations) {
            var x1 = 1;
            var y1 = 2;
            var x2 = 3;
            var y2 = 4;
            repeat (iterations) {
                var result = x1 * x2 + y1 * y2;
            }
        }),
        new TestCase("2D, runtime", function(iterations) {
            var x1 = 1;
            var y1 = 2;
            var x2 = 3;
            var y2 = 4;
            repeat (iterations) {
                var result = dot_product(x1, y1, x2, y2);
            }
        }),
        new TestCase("3D, manually", function(iterations) {
            var x1 = 1;
            var y1 = 2;
            var z1 = 3;
            var x2 = 4;
            var y2 = 5;
            var z2 = 6;
            repeat (iterations) {
                var result = x1 * x2 + y1 * y2 + z1 * z2;
            }
        }),
        new TestCase("3D, runtime", function(iterations) {
            var x1 = 1;
            var y1 = 2;
            var z1 = 3;
            var x2 = 4;
            var y2 = 5;
            var z2 = 6;
            repeat (iterations) {
                var result = dot_product_3d(x1, y1, z1, x2, y2, z2);
            }
        })
    ]),
    #endregion
    
    #region loop iterations
    new Benchmark("Fast Loops", [
        new TestCase("for over array size", function(iterations) {
            var test_array = self.test_array;
            for (var i = 0; i < array_length(test_array); i++) {
                var val = test_array[i];
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
        
        new TestCase("for over cached array size", function(iterations) {
            var test_array = self.test_array;
            for (var i = 0, n = array_length(test_array); i < n; i++) {
                var val = test_array[i];
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
        
        new TestCase("repeat over array", function(iterations) {
            var test_array = self.test_array;
            var i = 0;
            repeat (array_length(test_array)) {
                var val = test_array[i];
                i++;
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
        
        new TestCase("while over array", function(iterations) {
            var test_array = self.test_array;
            var i = 0;
            while (i < array_length(test_array)) {
                var val = test_array[i];
                i++;
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
        
        new TestCase("while over cached array size", function(iterations) {
            var test_array = self.test_array;
            var i = 0;
            var n = array_length(test_array);
            while (i < n) {
                var val = test_array[i];
                i++;
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        })
    ]),
    #endregion
    
    #region variable access
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
    #endregion
    
    #region recycling matrices
    new Benchmark("Recycling the identity matrix", [
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
        }),
        new TestCase("caching it in a static", function(iterations) {
            static identity = matrix_build_identity();
            repeat (iterations) {
                matrix_set(matrix_world, identity);
            }
        })
    ]),
    #endregion
    
    #region array FP
    new Benchmark("Array iteration", [
        new TestCase("for loop, the not stupid way", function(iterations) {
            var test_array = self.test_array;
            var t = 0;
            for (var i = 0, n = array_length(test_array); i < n; i++) {
                t += test_array[i];
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
        
        new TestCase("for loop, the stupid way", function(iterations) {
            var test_array = self.test_array;
            var t = 0;
            for (var i = 0; i < array_length(test_array); i++) {
                t += test_array[i];
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
        
        new TestCase("repeat loop", function(iterations) {
            var test_array = self.test_array;
            var t = 0;
            var i = 0;
            repeat (array_length(test_array)) {
                t += test_array[i];
                i++;
            }
        }, function(iterations) {
            self.test_array = array_create(iterations);
        }),
        
        new TestCase("array_reduce", function(iterations) {
            var test_array = self.test_array;
            var t = array_reduce(test_array, function(previous, current) {
                return previous + current;
            });
        }, function(iterations) {
            self.test_array = array_create(iterations);
        })
    ]),
    #endregion
    
    #region matrix math
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
    #endregion
    
    #region string splitting
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
    #endregion
    
    #region array sorting scaling
    new Benchmark("Scaling Array Sort", [
        new TestCase("100 elements", function(iterations) {
            array_sort(self.test_array, true);
        }, function() {
            self.test_array = array_create_ext(100, function() {
                return random(1000);
            });
        }),
        
        new TestCase("1,000 elements", function(iterations) {
            array_sort(self.test_array, true);
        }, function() {
            self.test_array = array_create_ext(1000, function() {
                return random(1000);
            });
        }),
        
        new TestCase("10,000 elements", function(iterations) {
            array_sort(self.test_array, true);
        }, function() {
            self.test_array = array_create_ext(10_000, function() {
                return random(1000);
            });
        }),
        
        new TestCase("100,000 elements", function(iterations) {
            array_sort(self.test_array, true);
        }, function() {
            self.test_array = array_create_ext(100_000, function() {
                return random(1000);
            });
        }),
        
        new TestCase("1,000,000 elements", function(iterations) {
            array_sort(self.test_array, true);
        }, function() {
            self.test_array = array_create_ext(1_000_000, function() {
                return random(1000);
            });
        })
    ]),
    #endregion
    
    #region OOP style calls vs procedural style calls
    new Benchmark("OOP vs Procedural", [
        new TestCase("OOP Static", function(iterations) {
            var test_inst = self.test_inst;
            repeat (iterations) {
                test_inst.Add();
            }
        }, function() {
            function Benchmark_OOPvsProcedural() constructor {
                a = random(1000);
                b = random(1000);
                
                static Add = function() { return a + b; };
            }
            self.test_inst = new Benchmark_OOPvsProcedural();
        }),
        new TestCase("OOP Non-static", function(iterations) {
            var test_inst = self.test_inst;
            repeat (iterations) {
                test_inst.Add();
            }
        }, function() {
            function Benchmark_OOPvsProcedural_NonStatic() constructor {
                a = random(1000);
                b = random(1000);
                
                Add = function() { return a + b; };
            }
            self.test_inst = new Benchmark_OOPvsProcedural_NonStatic();
        }),
        new TestCase("OOP + Procedural Hybrid", function(iterations) {
            var test_inst = self.test_inst;
            var b = random(1000);
            repeat (iterations) {
                test_inst.Add(b);
            }
        }, function() {
            function Benchmark_OOPvsProcedural_Hybrid() constructor {
                a = random(1000);
                
                static Add = function(b) { return a + b; };
            }
            self.test_inst = new Benchmark_OOPvsProcedural_Hybrid();
        }),
        new TestCase("Procedural", function(iterations) {
            var a = random(1000);
            var b = random(1000);
            repeat (iterations) {
                benchmark_oopvsprocedural_pureprocedural(a, b);
            }
        }, function() {
            function benchmark_oopvsprocedural_pureprocedural(a, b) {
                return a + b;
            }
        })
    ])
    #endregion
];