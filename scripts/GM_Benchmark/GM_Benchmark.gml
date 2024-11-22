function add_inline(a, b) {
    gml_pragma("forceinline");
    return a + b;
}

function add_nope(a, b) {
    return a + b;
}


function validate_number(s) {
    try {
        return true;
    } catch (e) {
        return false;
    }
}

function validate_number_dino(s) {
    var n = string_length(string_digits(s));
    var p = string_pos(".", s);
    var e = string_pos("e", s);
    switch (e) {
        case 0: break; // ok!
        case 1: return false; // "e#"
        case 2: if (p > 0) return false; break; // ".e#" or "1e."
        default: if (p > 0 && e < p) return false; break; // "1e3.3"
    }
    return n && n == string_length(s) - (string_char_at(s, 1) == "-") - (p != 0) - (e != 0);
}

function array_max_toolbox(_array, _offset = 0, _length = undefined) {
    // resolving the offset and length
    var _arrlength = array_length(_array);
    _length ??= _arrlength;
    
    if (_offset < 0)
        _offset = max(_arrlength + _offset, 0);
    
    if (_length < 0) {
        _length = min(_offset + 1, -_length);
        _offset -= _length - 1;
    }
    
    _length = min(_arrlength - _offset, _length);
    if (_length <= 0)
        return 0;
    
    // performing the actual calculation
    if (_length <= 10000)
        return script_execute_ext(max, _array, _offset, _length);
    
    var _max = -infinity;
    for (var i = 0; i < _length; i += 10000) {
        var _partial_max = script_execute_ext(max, _array, _offset + i, min(10000, _length - i));
        _max = max(_max, _partial_max);
    }
    return _max;
}

function array_max_fp(array, offset = 0, length = array_length(array)) {
    return array_reduce(array, function(previous, val) {
        return min(previous, val);
    }, -infinity, offset, length);
}

var n = 100;
global.big_test_array = array_create(n);
global.big_test_queue = ds_queue_create();
global.big_test_stack = ds_stack_create();
global.big_test_array_stack = array_create(n);
repeat (n) {
    ds_queue_enqueue(global.big_test_queue, 0);
    ds_stack_push(global.big_test_stack, 0);
}

function __vbm_mat4inverse(outmat4, msrc) {
    // Source MESA GLu library: https://www.mesa3d.org/
    
    var d;	// Determinant
    outmat4[@ 0] = msrc[ 5]*msrc[10]*msrc[15]-msrc[ 5]*msrc[11]*msrc[14]-msrc[ 9]*msrc[ 6]*msrc[15]+msrc[ 9]*msrc[ 7]*msrc[14]+msrc[13]*msrc[ 6]*msrc[11]-msrc[13]*msrc[ 7]*msrc[10];
    outmat4[@ 4] =-msrc[ 4]*msrc[10]*msrc[15]+msrc[ 4]*msrc[11]*msrc[14]+msrc[ 8]*msrc[ 6]*msrc[15]-msrc[ 8]*msrc[ 7]*msrc[14]-msrc[12]*msrc[ 6]*msrc[11]+msrc[12]*msrc[ 7]*msrc[10];
    outmat4[@ 8] = msrc[ 4]*msrc[ 9]*msrc[15]-msrc[ 4]*msrc[11]*msrc[13]-msrc[ 8]*msrc[ 5]*msrc[15]+msrc[ 8]*msrc[ 7]*msrc[13]+msrc[12]*msrc[ 5]*msrc[11]-msrc[12]*msrc[ 7]*msrc[ 9];
    outmat4[@12] =-msrc[ 4]*msrc[ 9]*msrc[14]+msrc[ 4]*msrc[10]*msrc[13]+msrc[ 8]*msrc[ 5]*msrc[14]-msrc[ 8]*msrc[ 6]*msrc[13]-msrc[12]*msrc[ 5]*msrc[10]+msrc[12]*msrc[ 6]*msrc[ 9];
    outmat4[@ 1] =-msrc[ 1]*msrc[10]*msrc[15]+msrc[ 1]*msrc[11]*msrc[14]+msrc[ 9]*msrc[ 2]*msrc[15]-msrc[ 9]*msrc[ 3]*msrc[14]-msrc[13]*msrc[ 2]*msrc[11]+msrc[13]*msrc[ 3]*msrc[10];
    outmat4[@ 5] = msrc[ 0]*msrc[10]*msrc[15]-msrc[ 0]*msrc[11]*msrc[14]-msrc[ 8]*msrc[ 2]*msrc[15]+msrc[ 8]*msrc[ 3]*msrc[14]+msrc[12]*msrc[ 2]*msrc[11]-msrc[12]*msrc[ 3]*msrc[10];
    outmat4[@ 9] =-msrc[ 0]*msrc[ 9]*msrc[15]+msrc[ 0]*msrc[11]*msrc[13]+msrc[ 8]*msrc[ 1]*msrc[15]-msrc[ 8]*msrc[ 3]*msrc[13]-msrc[12]*msrc[ 1]*msrc[11]+msrc[12]*msrc[ 3]*msrc[ 9];
    outmat4[@13] = msrc[ 0]*msrc[ 9]*msrc[14]-msrc[ 0]*msrc[10]*msrc[13]-msrc[ 8]*msrc[ 1]*msrc[14]+msrc[ 8]*msrc[ 2]*msrc[13]+msrc[12]*msrc[ 1]*msrc[10]-msrc[12]*msrc[ 2]*msrc[ 9];
    outmat4[@ 2] = msrc[ 1]*msrc[ 6]*msrc[15]-msrc[ 1]*msrc[ 7]*msrc[14]-msrc[ 5]*msrc[ 2]*msrc[15]+msrc[ 5]*msrc[ 3]*msrc[14]+msrc[13]*msrc[ 2]*msrc[ 7]-msrc[13]*msrc[ 3]*msrc[ 6];
    outmat4[@ 6] =-msrc[ 0]*msrc[ 6]*msrc[15]+msrc[ 0]*msrc[ 7]*msrc[14]+msrc[ 4]*msrc[ 2]*msrc[15]-msrc[ 4]*msrc[ 3]*msrc[14]-msrc[12]*msrc[ 2]*msrc[ 7]+msrc[12]*msrc[ 3]*msrc[ 6];
    outmat4[@10] = msrc[ 0]*msrc[ 5]*msrc[15]-msrc[ 0]*msrc[ 7]*msrc[13]-msrc[ 4]*msrc[ 1]*msrc[15]+msrc[ 4]*msrc[ 3]*msrc[13]+msrc[12]*msrc[ 1]*msrc[ 7]-msrc[12]*msrc[ 3]*msrc[ 5];
    outmat4[@14] =-msrc[ 0]*msrc[ 5]*msrc[14]+msrc[ 0]*msrc[ 6]*msrc[13]+msrc[ 4]*msrc[ 1]*msrc[14]-msrc[ 4]*msrc[ 2]*msrc[13]-msrc[12]*msrc[ 1]*msrc[ 6]+msrc[12]*msrc[ 2]*msrc[ 5];
    outmat4[@ 3] =-msrc[ 1]*msrc[ 6]*msrc[11]+msrc[ 1]*msrc[ 7]*msrc[10]+msrc[ 5]*msrc[ 2]*msrc[11]-msrc[ 5]*msrc[ 3]*msrc[10]-msrc[ 9]*msrc[ 2]*msrc[ 7]+msrc[ 9]*msrc[ 3]*msrc[ 6];
    outmat4[@ 7] = msrc[ 0]*msrc[ 6]*msrc[11]-msrc[ 0]*msrc[ 7]*msrc[10]-msrc[ 4]*msrc[ 2]*msrc[11]+msrc[ 4]*msrc[ 3]*msrc[10]+msrc[ 8]*msrc[ 2]*msrc[ 7]-msrc[ 8]*msrc[ 3]*msrc[ 6];
    outmat4[@11] =-msrc[ 0]*msrc[ 5]*msrc[11]+msrc[ 0]*msrc[ 7]*msrc[ 9]+msrc[ 4]*msrc[ 1]*msrc[11]-msrc[ 4]*msrc[ 3]*msrc[ 9]-msrc[ 8]*msrc[ 1]*msrc[ 7]+msrc[ 8]*msrc[ 3]*msrc[ 5];
    outmat4[@15] = msrc[ 0]*msrc[ 5]*msrc[10]-msrc[ 0]*msrc[ 6]*msrc[ 9]-msrc[ 4]*msrc[ 1]*msrc[10]+msrc[ 4]*msrc[ 2]*msrc[ 9]+msrc[ 8]*msrc[ 1]*msrc[ 6]-msrc[ 8]*msrc[ 2]*msrc[ 5];

    d = 1.0 / (msrc[0] * outmat4[0] + msrc[1] * outmat4[4] + msrc[2] * outmat4[8] + msrc[3] * outmat4[12] + 0.00001);	// Assumes determinant > 0. Error otherwise
    outmat4[@ 0] = outmat4[ 0] * d; outmat4[@ 1] = outmat4[ 1] * d; outmat4[@ 2] = outmat4[ 2] * d; outmat4[@ 3] = outmat4[ 3] * d;
    outmat4[@ 4] = outmat4[ 4] * d; outmat4[@ 5] = outmat4[ 5] * d; outmat4[@ 6] = outmat4[ 6] * d; outmat4[@ 7] = outmat4[ 7] * d;
    outmat4[@ 8] = outmat4[ 8] * d; outmat4[@ 9] = outmat4[ 9] * d; outmat4[@10] = outmat4[10] * d; outmat4[@11] = outmat4[11] * d;
    outmat4[@12] = outmat4[12] * d; outmat4[@13] = outmat4[13] * d; outmat4[@14] = outmat4[14] * d; outmat4[@15] = outmat4[15] * d;
}

Benchmarks = [
    #region arrays and queues
    new Benchmark("Matrix inverse", [
        new TestCase("built-in", function(iterations) {
            var M = matrix_build_identity();
            repeat (iterations) {
                var inv = matrix_inverse(M);
            }
        }), new TestCase("manual", function(iterations) {
            var M = matrix_build_identity();
            var out = array_create(16);
            repeat (iterations) {
                __vbm_mat4inverse(M, out);
            }
        })
    ]),
    #endregion
    
    #region buffer access
    new Benchmark("Buffer Access", [
        new TestCase("array read", function(iterations) {
            var array = array_create(iterations);
            var i = 0;
            repeat (iterations) {
                var n = array[i++];
            }
        }), new TestCase("array write", function(iterations) {
            var array = array_create(iterations);
            var i = 0;
            repeat (iterations) {
                array[i++] = 10;
            }
        }), new TestCase("buffer_read", function(iterations) {
            var buffer = buffer_create(iterations, buffer_fast, 1);
            repeat (iterations) {
                buffer_read(buffer, buffer_u8);
            }
        }), new TestCase("buffer_write", function(iterations) {
            var buffer = buffer_create(iterations, buffer_fast, 1);
            repeat (iterations) {
                buffer_write(buffer, buffer_u8, 10);
            }
        }), new TestCase("buffer_peek", function(iterations) {
            var buffer = buffer_create(iterations, buffer_fast, 1);
            var i = 0;
            repeat (iterations) {
                buffer_peek(buffer, buffer_u8, i++);
            }
        }), new TestCase("buffer_poke", function(iterations) {
            var buffer = buffer_create(iterations, buffer_fast, 1);
            var i = 0;
            repeat (iterations) {
                buffer_poke(buffer, i++, buffer_u8, 10);
            }
        }),
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

    #region math functions
    new Benchmark("Math Functions", [
        new TestCase("Multiplication", function(iterations) {
            var a = 1.23;
            var b = 4.56;
            repeat (iterations) {
                var result = a * b;
            }
        }),
        new TestCase("Division", function(iterations) {
            var a = 1.23;
            var b = 4.56;
            repeat (iterations) {
                var result = a / b;
            }
        }),
        new TestCase("Sine", function(iterations) {
            var a = 1.23;
            repeat (iterations) {
                var result = sin(a);
            }
        }),
        new TestCase("Sqare", function(iterations) {
            var a = 1.23;
            repeat (iterations) {
                var result = sqr(a);
            }
        }),
        new TestCase("Square root", function(iterations) {
            var a = 1.23;
            repeat (iterations) {
                var result = sqrt(a);
            }
        })
    ]),
    #endregion
    
    #region method types
    new Benchmark("Method Types", [
        new TestCase("Static", function(iterations) {
            var t = new (function() constructor {
                static m = function() {
                };
            })();
            
            repeat (iterations) {
                t.m();
            }
        }),
        new TestCase("Non-Static", function(iterations) {
            var t = new (function() constructor {
                self.m = function() {
                };
            })();
            
            repeat (iterations) {
                t.m();
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
        }), new TestCase("local", function(iterations) {
            var local = 0;
            var hash = variable_get_hash("x");
            repeat (iterations) {
                var val = local;
            }
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
    #region Struct vec2s vs two floats in a trench coat
    new Benchmark("3D Vector allocation", [
        new TestCase("Struct", function(iterations) {
            repeat (iterations) {
                var vector = new Vector3(100, 100, 100);
            }
        }),
        new TestCase("Array", function(iterations) {
            repeat (iterations) {
                var vector = avec3(100, 200, 300);
            }
        }),
/*
        new TestCase("C++", function(iterations) {
            repeat (iterations) {
                var vector = v3_create(100, 100, 100);
            }
        })*/
    ]),
    new Benchmark("3D Vector addition", [
        new TestCase("Struct", function(iterations) {
            var a = new Vector3(100, 100, 300);
            var b = new Vector3(200, 200, 300);
            repeat (iterations) {
                var result = a.Add(b);
            }
        }),
        new TestCase("Array", function(iterations) {
            var a = avec3(100, 200, 300);
            var b = avec3(100, 200, 300);
            repeat (iterations) {
                var result = avec2_add(a, b);
            }
        }),
/*        new TestCase("C++", function(iterations) {
            var a = v3_create(100, 200, 300);
            var b = v3_create(100, 200, 300);
            repeat (iterations) {
                var result = v3_add(a, b);
            }
        })*/
    ]),
    new Benchmark("3D Vector dot product", [
        new TestCase("Struct", function(iterations) {
            var a = new Vector3(100, 100, 300);
            var b = new Vector3(200, 200, 300);
            repeat (iterations) {
                var result = a.Dot(b);
            }
        }),
        new TestCase("Array", function(iterations) {
            var a = avec3(100, 100, 300);
            var b = avec3(200, 200, 300);
            repeat (iterations) {
                var result = avec2_dot(a, b);
            }
        }),
/*        new TestCase("C++", function(iterations) {
            var a = v3_create(100, 100, 300);
            var b = v3_create(200, 200, 300);
            repeat (iterations) {
                var result = v3_dot(a, b);
            }
        })*/
    ]),
    #endregion
    #region Variable access
    new Benchmark("Variable access", [
        new TestCase("Global", function(iterations) {
            global.some_value = 100;
            repeat (iterations) {
                var result = global.some_value;
            }
        }),
        new TestCase("Instance", function(iterations) {
            self.some_value = 100;
            repeat (iterations) {
                var result = self.some_value;
            }
        }),
        new TestCase("Local", function(iterations) {
            var some_value = 100;
            repeat (iterations) {
                var result = some_value;
            }
        })
    ])
    #endregion
];

#region definitions
function Vector2(x, y) constructor {
    self.x = x;
    self.y = y;
    static Add = function(vec) {
        return new Vector2(self.x + vec.x, self.y + vec.y);
    };
    static Dot = function(vec) {
        return dot_product(vec.x, vec.y, self.x, self.y);
    };
}

function Vector3(x, y, z) constructor {
    self.x = x;
    self.y = y;
    self.z = z;
    static Add = function(vec) {
        return new Vector3(self.x + vec.x, self.y + vec.y, self.z + vec.z);
    };
    static Dot = function(vec) {
        return dot_product_3d(vec.x, vec.y, vec.z, self.x, self.y, self.z);
    };
}

function svec2(x, y) {
    static buffer = buffer_create(8, buffer_fixed, 4);
    buffer_poke(buffer, 0, buffer_f32, x);
    buffer_poke(buffer, 4, buffer_f32, y);
    return buffer_peek(buffer, 0, buffer_u64);
}
function svec2_add(v1, v2) {
    static buffer = buffer_create(16, buffer_fixed, 4);
    static buffer_out = buffer_create(8, buffer_fixed, 4);
    buffer_poke(buffer, 0, buffer_u64, v1);
    buffer_poke(buffer, 8, buffer_u64, v2);
    buffer_poke(buffer_out, 0, buffer_f32, buffer_peek(buffer, 0, buffer_f32) + buffer_peek(buffer, 8, buffer_f32));
    buffer_poke(buffer_out, 4, buffer_f32, buffer_peek(buffer, 4, buffer_f32) + buffer_peek(buffer, 12, buffer_f32));
    return buffer_peek(buffer_out, 0, buffer_u64);
}
function svec2_dot(v1, v2) {
    static buffer = buffer_create(16, buffer_fixed, 4);
    buffer_poke(buffer, 0, buffer_u64, v1);
    buffer_poke(buffer, 8, buffer_u64, v2);
    return dot_product(
        buffer_peek(buffer, 0, buffer_f32),
        buffer_peek(buffer, 4, buffer_f32),
        buffer_peek(buffer, 8, buffer_f32),
        buffer_peek(buffer, 12, buffer_f32)
    );
}

function svec2_x(vec) {
    static buffer = buffer_create(8, buffer_fixed, 4);
    buffer_poke(buffer, 0, buffer_u64, vec);
    return buffer_peek(buffer, 0, buffer_f32);
}

function svec2_y(vec) {
    static buffer = buffer_create(8, buffer_fixed, 4);
    buffer_poke(buffer, 0, buffer_u64, vec);
    return buffer_peek(buffer, 4, buffer_f32);
}

function avec2(x, y) {
    return [x, y];
}

function avec2_add(v1, v2) {
    return [v1[0] + v2[0], v1[1] + v2[1]];
}

function avec2_dot(v1, v2) {
    return v1[0] * v2[0] + v1[1] * v2[1];
}

function avec3(x, y, z) {
    return [x, y, z];
}

function avec3_add(v1, v2) {
    return [v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2]];
}

function avec3_dot(v1, v2) {
    return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
}
#endregion