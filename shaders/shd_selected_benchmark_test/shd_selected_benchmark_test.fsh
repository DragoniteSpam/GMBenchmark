varying vec4 v_vColour;

float Dither2x2(vec2 position) {
    int x = int(min(mod(position.x, 6.0), 2.0));
    int y = int(min(mod(position.y, 6.0), 2.0));
    int index = x + y * 2;
    float limit = 0.0;
    
    if (x < 8) {
        if (index == 0) limit = 0.25;
        if (index == 1) limit = 0.75;
        if (index == 2) limit = 1.00;
        if (index == 3) limit = 0.50;
    }
    
    return limit;
}

vec4 GetDither(in vec4 base) {
    // the dither effect is just an inverse color
    return vec4(mix(base.rgb, vec3(1) - base.rgb, Dither2x2(gl_FragCoord.xy)), base.a);
}

void main() {
    gl_FragColor = GetDither(v_vColour);
}
